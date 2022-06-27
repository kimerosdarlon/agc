//
//  OccurrenceGeneralDetailViewController.swift
//  CAD
//
//  Created by Samir Chaves on 14/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import MapKit

struct RuntimeError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}

class OccurrenceGeneralDetailViewController: UIViewController {
    weak var updateDelegate: OccurrenceDataUpdateDelegate?

    private let occurrence: OccurrenceDetails

    @CadServiceInject
    private var cadService: CadService

    @OccurrenceServiceInject
    private var service: OccurrenceService

    private var locationManager = CLLocationManager()
    private var currentLocation: [Double]?

    private var canEdit: Bool = false

    private var mapView = MKMapView()
    private let locationErrorView: UIView = {
        let view = UIView()
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(blurView)
        let textLabel = UILabel.build(withSize: 15, color: .appTitle, alignment: .center, text: "A ocorrência atual não foi georreferenciada.")
        view.addSubview(textLabel)
        textLabel.centerY(view: view).centerX(view: view).width(view.widthAnchor, multiplier: 0.9)
        view.isHidden = true
        return view.enableAutoLayout()
    }()
    private var mapHeightConstraint: NSLayoutConstraint!
    private let openMapBtn: UIButton = {
        let image = UIImage(systemName: "map.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .custom)
        btn.frame = .init(x: 5, y: 5, width: 150, height: 30)
        btn.layer.cornerRadius = btn.bounds.height * 0.5
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 13)
        btn.backgroundColor = .appBlue
        btn.addTarget(self, action: #selector(didTapOnRouteBtn), for: .allEvents)
        btn.setTitle(" Navegar até o local", for: .normal)
        return btn.enableAutoLayout().height(30).width(170)
    }()

    private var mainOccurrenceBtn = AGCRoundedButton(text: "Ir para a ocorrência principal", loadingText: "Buscando").enableAutoLayout().height(40).width(210)

    private let container: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.enableAutoLayout()
        return scrollView
    }()

    private let propertiesList: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.enableAutoLayout()
        return stack
    }()

    init(occurrence: OccurrenceDetails) {
        self.occurrence = occurrence
        super.init(nibName: nil, bundle: nil)

        if let dispatchedOccurrence = self.cadService.getDispatchedOccurrence(),
           dispatchedOccurrence.occurrenceId == occurrence.occurrenceId {
            canEdit = true
        }

        locationManager.delegate = self
        title = "Dados Básicos"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setPinUsingMKPlacemark(location: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Local da Ocorrência"
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }

    @objc func goToMainOccurrence() {
        mainOccurrenceBtn.startLoad()
        if let mainOccurrenceId = occurrence.generalInfo.mainOccurrenceId {
            service.getOccurrenceById(mainOccurrenceId) { result in
                garanteeMainThread {
                    self.mainOccurrenceBtn.stopLoad()
                    switch result {
                    case .success(let details):
                        self.navigationController?.pushViewController(OccurrenceDetailViewController(occurrence: details), animated: true)
                    case .failure(let error as NSError):
                        self.showErrorPage(
                            title: "Não foi possível carregar a ocorrência pricipal",
                            error: error,
                            onRetry: {
                                self.goToMainOccurrence()
                            }
                        )
                    }
                }
            }
        }
    }

    @objc func didTapOnRouteBtn() {
        let address = occurrence.address
        let formattedAddress = address.getFormattedAddress()
        let destCoordinate = CLLocationCoordinate2D(
            latitude: address.coordinates?.latitude ?? 0,
            longitude: address.coordinates?.longitude ?? 0
        )
        let srcCoordinates = currentLocation.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
        self.openMaps(from: srcCoordinates, to: destCoordinate, withTitle: formattedAddress)
    }

    private func getPlaceView(address: Location) -> UIView {
        let formattedAddress = address.getFormattedAddress(withCoordinates: true)

        let placeView = UIStackView().enableAutoLayout()
        placeView.axis = .vertical
        placeView.distribution = .fillProportionally
        placeView.alignment = .fill
        placeView.spacing = 10
        let regions = ["\(occurrence.operatingRegion.initials) / \(occurrence.operatingRegion.agency.initials)"]
        let tagsView = TagGroupView(tags: regions, backGroundCell: .clear, containerBackground: .clear, tagBordered: true)
        placeView.addArrangedSubviewList(
            views: UILabel.build(withSize: 14, color: UIColor.appTitle.withAlphaComponent(0.8), text: formattedAddress),
            UILabel.build(withSize: 12, weight: .bold, color: UIColor.appTitle, text: "Tipo de Local"),
            UILabel.build(withSize: 14, color: UIColor.appTitle.withAlphaComponent(0.8), text: address.placeTypeDescription ?? String.emptyProperty),
            tagsView
        )
        tagsView.enableAutoLayout().height(40).width(placeView)

        return placeView
    }

    private func getAddressProperty() -> OccurrencePropertyView {
        let placeView = getPlaceView(address: occurrence.address)
        let addressProperty = OccurrencePropertyView(
            title: "Local",
            descriptionView: placeView,
            iconName: "place",
            editable: canEdit
        )
        addressProperty.onEdit = {
            guard let activeTeamId = self.cadService.getActiveTeam()?.id else { return }
            let addressUpdate = self.occurrence.toAddressUpdate(teamId: activeTeamId)
            let addressUpdateViewController = AddressUpdateViewController(
                occurrenceId: self.occurrence.occurrenceId, addressUpdate: addressUpdate
            )
            addressUpdateViewController.updateDelegate = self.updateDelegate
            self.navigationController?.pushViewController(addressUpdateViewController, animated: true)
        }
        return addressProperty
    }

    private func getNaturesProperty() -> OccurrenceTagsPropertyView {
        let naturesProperty = OccurrenceTagsPropertyView(
            title: "Naturezas",
            tags: occurrence.natures.map { $0.name },
            iconName: "handcuffs",
            editable: canEdit
        )
        naturesProperty.onEdit = {
            guard let activeTeamId = self.cadService.getActiveTeam()?.id else { return }
            let naturesUpdateViewController = GeneralOccurrenceNaturesUpdate(
                teamId: activeTeamId,
                occurrenceId: self.occurrence.occurrenceId,
                agencyId: self.occurrence.operatingRegion.agency.id,
                currentNatures: self.occurrence.natures
            )
            naturesUpdateViewController.updateDelegate = self.updateDelegate
            self.navigationController?.pushViewController(naturesUpdateViewController, animated: true)
        }
        return naturesProperty
    }

    private func buildPropertyList() -> [OccurrencePropertyView] {
        let address = occurrence.address

        if let coodinates = address.coordinates {
            setPinUsingMKPlacemark(location: .init(latitude: coodinates.latitude, longitude: coodinates.longitude))
            locationErrorView.isHidden = true
            openMapBtn.isHidden = false
        } else {
            locationErrorView.isHidden = false
            openMapBtn.isHidden = true
        }

        var registrations = [(
            title: "Registro do Atendimento em",
            description: occurrence.generalInfo.serviceRegisteredAt.format()
        ), (
            title: "Registro do Despacho em",
            description: occurrence.generalInfo.occurrenceRegisteredAt.format()
        )]

        if let firstDispatch = occurrence.firstTeamDispatched {
            let firstDispatchDatetimeOpt = firstDispatch.getDate(format: "yyyy-MM-dd'T'HH:mm:ss")?.format(to: "dd/MM/yyyy HH:mm:ss")
            let firstDispatchDatetime = firstDispatchDatetimeOpt.map { s in "\(s) \(firstDispatch.timeZone)" } ?? String.emptyProperty
            registrations.append((
                title: "Primeiro Empenho",
                description: "\(firstDispatchDatetime)\nEquipe \(firstDispatch.team.name)"
            ))
        }

        var operatorText = String.emptyProperty
        if let dispatcherOperator = occurrence.dispatcherOperator {
            operatorText = "\(dispatcherOperator.name)\n\(cpfMask(dispatcherOperator.cpf, hidden: true)!)"
        }

        var properties: [OccurrencePropertyView] = [
            getAddressProperty(),
            OccurrenceTextPropertyView(title: "Protocolo",
                                       description: occurrence.generalInfo.protocol,
                                       iconName: "file",
                                       extra: OccurrencePriorityLabel().withPriority(occurrence.generalInfo.priority)),
            OccurrencePropertyView(
                title: "Situação",
                descriptionView: OccurrenceSituationLabel().withSituation(occurrence.generalInfo.situation),
                iconName: "alarm"
            ),
            OccurrenceTextPropertyView(
                title: "Centro de Captação",
                description: occurrence.captureRegion.captureCenter.name,
                iconName: "captureCenter"
            ),
            OccurrenceMultilineTextPropertyView(registrations, iconName: "calendar"),
            OccurrenceMultilineTextPropertyView(
                [(title: "Despachante", description: operatorText),
                 (title: "Atendente", description: "\(occurrence.receiver.name)\n\(cpfMask(occurrence.receiver.cpf, hidden: true)!)")],
                iconName: "operator"
            ),
            getNaturesProperty(),
            OccurrenceTextPropertyView(title: "Narrativa",
                                       description: occurrence.activities ?? String.emptyProperty,
                                       iconName: "occurrenceActivities"),
            OccurrenceTextPropertyView(title: "Relato do Despachante",
                                       description: occurrence.narrative ?? String.emptyProperty,
                                       iconName: "narrative")
        ]

        if canEdit {
            let activeTeamIdOptional = cadService.getActiveTeam()?.id
            let report = activeTeamIdOptional.flatMap { activeTeamId in
                occurrence.dispatches
                    .sorted(by: { (dispatch1, dispatch2) in
                        guard let date1 = dispatch1.getDate(format: "yyyy-MM-dd'T'HH:mm:ss"),
                              let date2 = dispatch2.getDate(format: "yyyy-MM-dd'T'HH:mm:ss") else { return true }
                        return date1.compare(date2) == .orderedDescending
                    })
                    .first(where: { $0.team.id == activeTeamId })?.report
            }
            let reportProperty = OccurrenceTextPropertyView(title: "Relato do Agente de Campo",
                                                            description: report ?? String.emptyProperty,
                                                            iconName: "exclamationmark.bubble.fill",
                                                            editable: canEdit)
            properties.append(reportProperty)
            reportProperty.onEdit = {
                guard let activeTeamId = self.cadService.getActiveTeam()?.id else { return }
                let reportUpdateViewController = ReportUpdateViewController(
                    initialReport: report ?? "",
                    teamId: activeTeamId,
                    occurrenceId: self.occurrence.occurrenceId
                )
                reportUpdateViewController.updateDelegate = self.updateDelegate
                self.navigationController?.pushViewController(reportUpdateViewController, animated: true)
            }
        }

        if let finalization = occurrence.finalization {
            let dateTimeWithTimezone = DateTimeWithTimeZone(dateTime: finalization.dateTime, timeZone: occurrence.generalInfo.occurrenceRegisteredAt.timeZone)
            let finalizationFormattedDatetime = dateTimeWithTimezone.format()
            let finalizationAuthorName = finalization.owner?.name ?? String.emptyProperty
            let finalizationAuthorCpf = cpfMask(finalization.owner?.cpf, hidden: true).map { cpf in "\n\(cpf)" } ?? ""
            let finalizationDescription = finalization.eventDescription
            let finalizationProperty = OccurrenceMultilineTextPropertyView(
                [(
                    title: "Finalização da Ocorrência em",
                    description: finalizationFormattedDatetime
                ), (
                    title: "Feita por",
                    description: "\(finalizationAuthorName)\(finalizationAuthorCpf)"
                ), (
                    title: "Descrição",
                    description: finalizationDescription
                )],
                iconName: "occurrenceEnd"
            )
            properties.insert(finalizationProperty, at: 5)
        }

        return properties
    }

    private func addSubViews() {
        container.addSubview(propertiesList)
        container.addSubview(mapView)
        container.addSubview(locationErrorView)
        container.addSubview(openMapBtn)
        container.addSubview(mainOccurrenceBtn)
        openMapBtn.top(to: container.topAnchor, mutiplier: 1)
        openMapBtn.left(container.trailingAnchor, mutiplier: 1)

        if occurrence.generalInfo.mainOccurrenceId == nil {
            mainOccurrenceBtn.isHidden = true
        }
        mainOccurrenceBtn.titleLabel?.font = UIFont.robotoMedium.withSize(14)
        mainOccurrenceBtn.addTarget(self, action: #selector(goToMainOccurrence), for: .touchUpInside)

        propertiesList.addArrangedSubviewList(views: buildPropertyList())

        view.addSubview(container)
    }

    private func layoutConstraints() {
        container.fillSuperView(regardSafeArea: true)
        propertiesList.width(container)
        let safeArea = view.safeAreaLayoutGuide
        mainOccurrenceBtn.layer.cornerRadius = 20
        NSLayoutConstraint.activate([
            mainOccurrenceBtn.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            mainOccurrenceBtn.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -15),
            propertiesList.topAnchor.constraint(equalTo: mainOccurrenceBtn.bottomAnchor, constant: 10),
            
            mapView.topAnchor.constraint(equalTo: container.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            locationErrorView.topAnchor.constraint(equalTo: mapView.topAnchor),
            locationErrorView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            locationErrorView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            locationErrorView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor),

            container.topAnchor.constraint(equalTo: safeArea.topAnchor),
            container.bottomAnchor.constraint(equalTo: propertiesList.bottomAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: container.bottomAnchor, multiplier: 1)
        ])
    }

    override func viewDidLoad() {
        addSubViews()
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapHeightConstraint = mapView.heightAnchor.constraint(equalToConstant: 300)
        mapHeightConstraint.isActive = true
        layoutConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension OccurrenceGeneralDetailViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinates = locations.last?.coordinate {
            currentLocation = [Double(coordinates.latitude), Double(coordinates.longitude)]
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
