//
//  AddressUpdateViewController.swift
//  CAD
//
//  Created by Samir Chaves on 03/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import MapKit
import UIKit
import Logger

class AddressUpdateViewController: OccurrenceUpdateViewController<AddressUpdate> {
    internal let dataSource = AddressUpdateDataSource.shared

    internal var stateField: SelectComponent<String>?
    internal var cityField: SelectComponent<String>?
    private let streetField = TextFieldComponent(placeholder: "", label: "Rua", showLabel: false)
    private let numberField = TextFieldComponent(placeholder: "", label: "Número", showLabel: false)
    private let districtField = TextFieldComponent(placeholder: "", label: "Bairro", showLabel: false)
    private let complementField = TextFieldComponent(placeholder: "", label: "Complemento", showLabel: false)
    private let referencePointField = TextFieldComponent(placeholder: "", label: "Ponto de Referência", showLabel: false)
    internal var placeTypeField: SelectComponent<Int>?
    internal var roadTypeField: SelectComponent<String>?
    private let highwayField = TextFieldComponent(placeholder: "", label: "Rodovia", showLabel: false)
    internal var roadDirectionField: SelectComponent<String>?
    internal var highwayLaneField: SelectComponent<String>?
    private let stretchField = TextFieldComponent(placeholder: "", label: "Trecho", showLabel: false)
    private let kmField = TextFieldComponent(placeholder: "", label: "Km", keyboardType: .decimalPad, showLabel: false)

    private let mapView: AddressUpdateMapView
    
    private let searchDebounce = Debouncer(timeInterval: 1)

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    @CadServiceInject
    private var cadService: CadService

    private let occurrenceId: UUID

    internal var formBuilder: GenericForm<LocationUpdate>!
    internal var formView: GenericForm<LocationUpdate>.FormView!

    init(occurrenceId: UUID, addressUpdate: AddressUpdate) {
        self.occurrenceId = occurrenceId
        self.mapView = AddressUpdateMapView(occurrenceCoordinates: addressUpdate.address.coordinates?.toCLLocationCoordinate2D())

        super.init(model: addressUpdate, name: "Endereço", version: addressUpdate.address.version, canDelete: false)

        self.mapView.mapLocatorDelegate = self
        mapView.parentViewController = self

        setupPlaceTypeField()
        setupStateField()
        setupCityField()
        setupRoadTypeField()
        setupRoadLaneField()
        setupRoadDirectionField()

        dataSource.loadStates()

        formBuilder = GenericForm(model: model.address)
            .addField(stateField!, forKeyPath: \.state)
            .addField(cityField!, forKeyPath: \.city)
            .addField(streetField, forKeyPath: \.street)
            .addField(numberField, forKeyPath: \.number)
            .addField(districtField, forKeyPath: \.district)
            .addField(complementField, forKeyPath: \.complement)
            .addField(referencePointField, forKeyPath: \.referencePoint)
            .addField(placeTypeField!, forKeyPath: \.placeType)
            .addField(roadTypeField!, forKeyPath: \.roadType)
            .addField(highwayField, forKeyPath: \.highway)
            .addField(roadDirectionField!, forKeyPath: \.roadDirection)
            .addField(highwayLaneField!, forKeyPath: \.highwayLane)
            .addField(stretchField, forKeyPath: \.stretch)
            .addField(kmField, forKeyPath: \.km)
            .buildFormView()

        formView = formBuilder.formView

        if let currentStateInitials = addressUpdate.address.state,
           let selectedState = self.dataSource.states.first(where: { $0.initials == currentStateInitials }) {
            self.dataSource.selectedState = selectedState
            self.dataSource.loadCities()
        }

        self.setupListeners()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupListeners() {
        formBuilder.listenForChanges(in: \.city) { cityName in
            self.formBuilder.send(value: nil, toField: \.district)
            self.formBuilder.send(value: nil, toField: \.street)
            self.formBuilder.send(value: nil, toField: \.number)
            self.searchAddress()
        }
        formBuilder.listenForChanges(in: \.state) { value in
            if let value = value, !value.isEmpty {
                guard let selectedState = self.dataSource.states.first(where: { $0.initials == value }) else { return }
                self.dataSource.selectedState = selectedState
                self.dataSource.loadCities()
                self.formView?.showField(forKey: \LocationUpdate.city)
            } else {
                self.formBuilder?.send(value: nil, toField: \.city)
                self.formView?.hideField(forKey: \LocationUpdate.city)
            }
            self.formBuilder.send(value: nil, toField: \.district)
            self.formBuilder.send(value: nil, toField: \.street)
            self.formBuilder.send(value: nil, toField: \.number)
            self.formBuilder.send(value: nil, toField: \.city)
            self.searchAddress()
        }

        formBuilder.listenForChanges(in: \.street) { _ in self.searchAddress() }
        formBuilder.listenForChanges(in: \.number) { _ in self.searchAddress() }
        formBuilder.listenForChanges(in: \.district) { _ in self.searchAddress() }

        formBuilder.listenForChanges {
            self.model = AddressUpdate(
                address: self.formBuilder.model,
                teamId: self.model.teamId
            )
            let city = self.formBuilder.model.city.flatMap { self.dataSource.getCityByName($0) }
            self.model.address.ibgeCityCode = city.map { "\($0.ibgeCode)" }

            if self.formBuilder.isMerging {
                guard let currentVersion = self.remoteModel?.address.version else { return }
                let conflictingFields = self.getConflictingFields()
                self.formBuilder.setConflictsTo(fieldsKeys: conflictingFields, version: currentVersion)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.loadRoadData {
            garanteeMainThread {
                self.formBuilder?.send(value: self.model.address.roadType, toField: \.roadType)
                self.formBuilder?.send(value: self.model.address.highwayLane, toField: \.highwayLane)
                self.formBuilder?.send(value: self.model.address.roadDirection, toField: \.roadDirection)
            }
        }

        if dataSource.selectedState != nil {
            self.formBuilder?.send(value: self.model.address.city, toField: \.city)
        }

        formView.enableAutoLayout()
        mapView.enableAutoLayout()
        mapView.height(230)
        container.addSubview(mapView)
        container.addSubview(formView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: container.topAnchor),
            mapView.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -20),
            mapView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),

            formView.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -20),
            formView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            formView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 15),
            formView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0),

            container.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    private func searchAddress() {
        searchDebounce.renewInterval()
        searchDebounce.handler = {
            let addressModel = self.formBuilder.model
            let query = String.interpolateString(
                values: [addressModel.street, addressModel.number, addressModel.district, addressModel.city, addressModel.state],
                separators: [", ", " - ", ". ", " - "]
            )
            self.mapView.searchAddress(query: query) { result in
                guard let result = result,
                      let city = self.cityFrom(address: result.address) else { return }
                if let selectedCityCode = self.formBuilder.model.ibgeCityCode,
                   "\(city.ibgeCode)" != selectedCityCode {
                    let addressModel = self.formBuilder.model
                    let query = String.interpolateString(
                        values: [addressModel.city, addressModel.state],
                        separators: [" - "]
                    )
                    self.mapView.searchAddress(query: query) { _ in }
                }
            }
        }
    }

    private func getConflictingFields() -> [PartialKeyPath<LocationUpdate>: String?] {
        guard let remoteAddress = self.remoteModel?.address else { return [:] }
        let initialAddress = self.initialModel.address
        let address = self.model.address
        var conflictingFields = [PartialKeyPath<LocationUpdate>: String?]()

        if initialAddress.city != address.city &&
            initialAddress.city != remoteAddress.city &&
            address.city != remoteAddress.city {
            conflictingFields[\LocationUpdate.city] = remoteAddress.city.map {
                dataSource.getCityByName($0)?.name
            }
        }
        if initialAddress.state != address.state &&
            initialAddress.state != remoteAddress.state &&
            address.state != remoteAddress.state {
            conflictingFields[\LocationUpdate.state] = remoteAddress.state.map {
                dataSource.getStateByInitials($0)?.name
            }
        }
        if initialAddress.complement != address.complement &&
            initialAddress.complement != remoteAddress.complement &&
            address.complement != remoteAddress.complement {
            conflictingFields[\LocationUpdate.complement] = remoteAddress.complement
        }
        if initialAddress.street != address.street &&
            initialAddress.street != remoteAddress.street &&
            address.street != remoteAddress.street {
            conflictingFields[\LocationUpdate.street] = remoteAddress.street
        }
        if initialAddress.number != address.number &&
            initialAddress.number != remoteAddress.number &&
            address.number != remoteAddress.number {
            conflictingFields[\LocationUpdate.number] = remoteAddress.number
        }
        if initialAddress.placeType != address.placeType &&
            initialAddress.placeType != remoteAddress.placeType &&
            address.placeType != remoteAddress.placeType {
            conflictingFields[\LocationUpdate.placeType] = remoteAddress.placeType.map {
                dataSource.getPlaceTypeByCode($0)?.description
            }
        }
        if initialAddress.roadType != address.roadType &&
            initialAddress.roadType != remoteAddress.roadType &&
            address.roadType != remoteAddress.roadType {
            conflictingFields[\LocationUpdate.roadType] = remoteAddress.roadType.map {
                dataSource.getRoadTypeByKey($0)?.label
            }
        }
        if initialAddress.highway != address.highway &&
            initialAddress.highway != remoteAddress.highway &&
            address.highway != remoteAddress.highway {
            conflictingFields[\LocationUpdate.highway] = remoteAddress.highway
        }
        if initialAddress.highwayLane != address.highwayLane &&
            initialAddress.highwayLane != remoteAddress.highwayLane &&
            address.highwayLane != remoteAddress.highwayLane {
            conflictingFields[\LocationUpdate.highwayLane] = remoteAddress.highwayLane.map {
                dataSource.getRoadLaneByKey($0)?.label
            }
        }
        if initialAddress.district != address.district &&
            initialAddress.district != remoteAddress.district &&
            address.district != remoteAddress.district {
            conflictingFields[\LocationUpdate.district] = remoteAddress.district
        }
        if initialAddress.stretch != address.stretch &&
            initialAddress.stretch != remoteAddress.stretch &&
            address.stretch != remoteAddress.stretch {
            conflictingFields[\LocationUpdate.stretch] = remoteAddress.stretch
        }
        if initialAddress.km != address.km &&
            initialAddress.km != remoteAddress.km &&
            address.km != remoteAddress.km {
            conflictingFields[\LocationUpdate.km] = remoteAddress.km
        }
        if initialAddress.roadDirection != address.roadDirection &&
            initialAddress.roadDirection != remoteAddress.roadDirection &&
            address.roadDirection != remoteAddress.roadDirection {
            conflictingFields[\LocationUpdate.roadDirection] = remoteAddress.roadDirection.map {
                dataSource.getRoadwayByKey($0)?.label
            }
        }
        if initialAddress.referencePoint != address.referencePoint &&
            initialAddress.referencePoint != remoteAddress.referencePoint &&
            address.referencePoint != remoteAddress.referencePoint {
            conflictingFields[\LocationUpdate.referencePoint] = remoteAddress.referencePoint
        }

        return conflictingFields
    }

    override func setupConflictingState() {
        guard let remoteVersion = remoteModel?.address.version else { return }
        let conflictingFields = self.getConflictingFields()
        self.formBuilder.setConflictsTo(fieldsKeys: conflictingFields, version: remoteVersion)
    }

    func getResolvedModel() -> AddressUpdate {
        guard let remoteModel = self.remoteModel else { return self.model }
        let mergeResult = formBuilder.getConflictsMerging()
        let resolvedMerge = mergeResult.filter { $0.value != nil } as! [PartialKeyPath<LocationUpdate>: FieldConflictMergeStrategy]
        let fieldsResolvedAsTheirs = resolvedMerge.filter { $0.value == .theirs }.map { $0.key }

        let stateKeyPath = formBuilder.extractWritableKey(keyPath: \.state)
        let cityKeyPath = formBuilder.extractWritableKey(keyPath: \.city)
        let streetKeyPath = formBuilder.extractWritableKey(keyPath: \.street)
        let numberKeyPath = formBuilder.extractWritableKey(keyPath: \.number)
        let districtKeyPath = formBuilder.extractWritableKey(keyPath: \.district)
        let complementKeyPath = formBuilder.extractWritableKey(keyPath: \.complement)
        let referencePointKeyPath = formBuilder.extractWritableKey(keyPath: \.referencePoint)
        let placeTypeKeyPath = formBuilder.extractWritableKey(keyPath: \.placeType)
        let roadTypeKeyPath = formBuilder.extractWritableKey(keyPath: \.roadType)
        let highwayKeyPath = formBuilder.extractWritableKey(keyPath: \.highway)
        let roadDirectionKeyPath = formBuilder.extractWritableKey(keyPath: \.roadDirection)
        let highwayLaneKeyPath = formBuilder.extractWritableKey(keyPath: \.highwayLane)
        let stretchKeyPath = formBuilder.extractWritableKey(keyPath: \.stretch)
        let kmKeyPath = formBuilder.extractWritableKey(keyPath: \.km)

        fieldsResolvedAsTheirs.forEach { keyPath in
            if keyPath == stateKeyPath {
                self.model.address[keyPath: stateKeyPath] = remoteModel.address[keyPath: stateKeyPath]
            }
            if keyPath == cityKeyPath {
                self.model.address[keyPath: cityKeyPath] = remoteModel.address[keyPath: cityKeyPath]
            }
            if keyPath == streetKeyPath {
                self.model.address[keyPath: streetKeyPath] = remoteModel.address[keyPath: streetKeyPath]
            }
            if keyPath == numberKeyPath {
                self.model.address[keyPath: numberKeyPath] = remoteModel.address[keyPath: numberKeyPath]
            }
            if keyPath == districtKeyPath {
                self.model.address[keyPath: districtKeyPath] = remoteModel.address[keyPath: districtKeyPath]
            }
            if keyPath == complementKeyPath {
                self.model.address[keyPath: complementKeyPath] = remoteModel.address[keyPath: complementKeyPath]
            }
            if keyPath == referencePointKeyPath {
                self.model.address[keyPath: referencePointKeyPath] = remoteModel.address[keyPath: referencePointKeyPath]
            }
            if keyPath == placeTypeKeyPath {
                self.model.address[keyPath: placeTypeKeyPath] = remoteModel.address[keyPath: placeTypeKeyPath]
            }
            if keyPath == roadTypeKeyPath {
                self.model.address[keyPath: roadTypeKeyPath] = remoteModel.address[keyPath: roadTypeKeyPath]
            }
            if keyPath == highwayKeyPath {
                self.model.address[keyPath: highwayKeyPath] = remoteModel.address[keyPath: highwayKeyPath]
            }
            if keyPath == roadDirectionKeyPath {
                self.model.address[keyPath: roadDirectionKeyPath] = remoteModel.address[keyPath: roadDirectionKeyPath]
            }
            if keyPath == highwayLaneKeyPath {
                self.model.address[keyPath: highwayLaneKeyPath] = remoteModel.address[keyPath: highwayLaneKeyPath]
            }
            if keyPath == stretchKeyPath {
                self.model.address[keyPath: stretchKeyPath] = remoteModel.address[keyPath: stretchKeyPath]
            }
            if keyPath == kmKeyPath {
                self.model.address[keyPath: kmKeyPath] = remoteModel.address[keyPath: kmKeyPath]
            }
        }
        return self.model
    }

    private func doubleCheckConflict() {
        self.occurrenceService.getOccurrenceById(self.occurrenceId) { result in
            garanteeMainThread {
                self.stopLoading()
                switch result {
                case .success(let details):
                    guard let activeTeamId = self.cadService.getActiveTeam()?.id else { return }
                    self.remoteModel = details.toAddressUpdate(teamId: activeTeamId)
                    let conflictingFields = self.getConflictingFields()
                    if !conflictingFields.isEmpty {
                        self.showConflictAlert()
                    } else {
                        self.model.address.version = self.remoteModel!.address.version
                        self.updateOccurrence()
                    }
                case .failure(let error as NSError):
                    self.showErrorAlert(title: "Erro durando a atualização", message: error.domain)
                }
            }
        }
    }

    private func updateOccurrence() {
        startLoading()
        occurrenceService.update(occurrenceId: occurrenceId, address: self.model) { error in
            garanteeMainThread {
                self.stopLoading()
                if let error = error as NSError? {
                    if error.code == 422 && error.domain.lowercased().contains("conflito") {
                        self.doubleCheckConflict()
                    } else {
                        self.showErrorAlert(title: "Erro durando a atualização", message: error.domain)
                    }
                } else {
                    self.showSuccessAlert()
                }
            }
        }
    }

    override func didSave() {
        if formBuilder.isMerging {
            let mergeResult = formBuilder.getConflictsMerging()
            let pendingConflicts = mergeResult.filter { $0.value == nil }
            if !pendingConflicts.isEmpty {
                showPendingConflictsAlert()
            } else {
                self.model.address.version = self.model.address.version + 1
                self.model = self.getResolvedModel()
                updateOccurrence()
            }
        } else {
            self.updateOccurrence()
        }
    }

    private func stateFrom(address: GeocodeAddress) -> State? {
        return dataSource.states.first(where: { state in
            guard let selectedState = address.countrySubdivision?.prepareForSearch(),
                  let regex = try? NSRegularExpression(pattern: selectedState,
                                                       options: [.caseInsensitive, .ignoreMetacharacters])
            else { return false }
            return searchMatch(query: regex, with: state.name) != nil
        })
    }

    private func cityFrom(address: GeocodeAddress) -> City? {
        return dataSource.cities.first(where: { city in
            guard let selectedCity = address.municipality?.prepareForSearch(),
                  let regex = try? NSRegularExpression(pattern: selectedCity,
                                                       options: [.caseInsensitive, .ignoreMetacharacters])
            else { return false }
            return searchMatch(query: regex, with: city.name) != nil
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension AddressUpdateViewController: MapLocatorViewDelegate {
    func didConfirmChanges(address: GeocodeAddress, position: CLLocationCoordinate2D) {
        let state = stateFrom(address: address)

        if let state = state {
            dataSource.selectedState = state
            dataSource.loadCities()
            formBuilder.send(value: state.initials, toField: \.state)
        }

        let city = cityFrom(address: address)

        if let city = city {
            formBuilder.send(value: city.name.uppercased(), toField: \.city)
            self.model.address.ibgeCityCode = "\(city.ibgeCode)"
        }

        if let street = address.streetName {
            formBuilder.send(value: street, toField: \.street)
        }

        if let number = address.streetNumber {
            formBuilder.send(value: number, toField: \.number)
        }

        if let district = address.municipalitySubdivision {
            formBuilder.send(value: district, toField: \.district)
        }

        model.address.coordinates = LocationCoordinates(latitude: position.latitude, longitude: position.longitude)

        mapView.setOccurrenceCoordinates(position)
    }
}
