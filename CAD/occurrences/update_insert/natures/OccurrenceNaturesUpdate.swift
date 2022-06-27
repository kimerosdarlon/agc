//
//  OccurrenceNaturesUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 09/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import UIKit
import Combine

struct OccurrenceObjectNature: Hashable {
    let natureId: UUID
    let situationId: String?
}

class OccurrenceNaturesUpdate<T: OccurrenceObject>: UIView {
    internal let dataSource: NaturesDataSource<T.ObjectTypeUpdate>

    @OccurrenceServiceInject
    internal var occurrenceService: OccurrenceService

    @CadServiceInject
    internal var cadService: CadService

    @domainServiceInject
    internal var domainService: DomainService

    internal let titleLabel = UILabel.build(withSize: 13, weight: .bold, text: "Naturezas")
    internal let collapseIcon = UILabel.build(withSize: 30, weight: .light, alignment: .right, text: "-")
    internal let collapseHeader: UIView = {
        let view = UIView().enableAutoLayout()
        view.backgroundColor = .appBackground
        return view
    }()
    internal let loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView().enableAutoLayout()
        view.backgroundColor = UIColor.appBackground.withAlphaComponent(0.6)
        return view
    }()
    internal let collapseContainer = UIView().enableAutoLayout()
    internal var naturesTags: MultiselectorTagsCollectionView<NaturesVersion>!
    internal var naturesField: NatureSelectComponent!
    internal var situationsField: SelectComponent<String>!
    internal let addButton: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        let icon = UIImage(systemName: "plus")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        btn.setTitleColor(.appTitle, for: .normal)
        btn.setTitleColor(UIColor.appTitle.withAlphaComponent(0.7), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("Adicionar natureza", for: .normal)
        btn.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 5)
        btn.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 0)
        btn.setImage(icon, for: .normal)
        btn.layer.cornerRadius = 5
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.appTitle.cgColor
        btn.backgroundColor = .appBackgroundCell
        btn.addTarget(self, action: #selector(didTapOnAddButton), for: .touchUpInside)
        return btn
    }()
    internal var heightConstraint: NSLayoutConstraint?
    internal var isExpanded: Bool = true

    internal var selectedNatures = Set<NaturesVersion>()
    internal var selectedNewNatures = [NaturesVersion]()
    internal var isSelectedNatureNew: Bool = false
    internal var objectType: OccurrenceObjectType
    internal let occurrenceId: UUID
    internal var occurrenceNatures: [Nature]
    internal let parentViewController: UIViewController
    internal let object: T
    internal let teamId: UUID
    internal let forInsert: Bool

    private var subscriptions = Set<AnyCancellable>()

    init(occurrenceId: UUID, occurrenceNatures: [Nature],
         agencyId: String, teamId: UUID, object: OccurrenceNatures<T>,
         parentViewController: UIViewController, forInsert: Bool = false) {

        self.teamId = teamId
        self.object = object.component
        self.forInsert = forInsert
        self.objectType = self.object.getType()
        self.parentViewController = parentViewController
        self.occurrenceId = occurrenceId
        self.occurrenceNatures = occurrenceNatures
        self.dataSource = .init(
            agencyId: agencyId,
            object: self.object.toUpdate(
                teamId: teamId,
                idsVersions: object.objects.map { IdVersion(id: $0.id, version: $0.version) }
            ),
            objectType: objectType,
            needCreateExternalId: !object.component.hasExternalId()
        )
        self.selectedNatures = Set(object.objects)

        super.init(frame: .zero)

        self.naturesTags = MultiselectorTagsCollectionView<NaturesVersion>(
            tags: self.getNatureSelectedTags(),
            canBeEmpty: false
        ).enableAutoLayout()
        self.naturesTags.colorForTag = { tag in
            if let natureGroup = self.domainService.getGroupByNature(tag.value.nature),
               natureGroup == "Violência Doméstica" {
                return .appPurple
            }
            return .appBlue
        }

        var situationsFieldLabel = "Situação"
        switch objectType {
        case .involved:
            situationsFieldLabel = "Envolvimento"
        case .vehicle:
            situationsFieldLabel = "Envolvimento"
        default:
            situationsFieldLabel = "Situação"
        }
        naturesField = NatureSelectComponent(parentViewController: parentViewController,
                                             label: "Escolha a natureza",
                                             inputPlaceholder: "Toque para selecionar")
        naturesField.belongingNatures = Set(Array(occurrenceNatures).map { $0.id })

        situationsField = SelectComponent<String>(parentViewController: parentViewController,
                                                  label: situationsFieldLabel,
                                                  inputPlaceholder: "Toque para selecionar")
        dataSource.fetchNatures { _ in  }
        dataSource.fetchObjectData { _ in  }
        setupNaturesField()
        setupSituationsField()

        naturesTags.onRemoveASelection = { removedTag, completion in
            self.didRemoveANature(removedTag: removedTag, completion: completion)
        }

        naturesField.path.sink { value in
            self.setAddButtonEnability()
            guard let (natureId, isNewNature) = value else { return }
            self.addButton.isEnabled = true
            self.dataSource.selectedNature = natureId
            self.isSelectedNatureNew = isNewNature
        }.store(in: &subscriptions)

        situationsField.getSubject()?.sink { objectData in
            self.setAddButtonEnability()
            self.dataSource.selectedObjectData = objectData
        }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setAddButtonEnability() {
        let natureSubject = naturesField.path
        guard let situationSubject = situationsField.getSubject() else { return }
        if natureSubject.value != nil && situationSubject.value != nil {
            self.addButton.isUserInteractionEnabled = true
            self.addButton.isEnabled = true
            self.addButton.alpha = 1
        } else {
            self.addButton.isUserInteractionEnabled = false
            self.addButton.isEnabled = false
            self.addButton.alpha = 0.6
        }
    }

    func expand() {
        isExpanded = true
        collapseIcon.text = "-"
        UIView.animate(withDuration: 0.3) {
            self.collapseContainer.alpha = 1
            self.heightConstraint?.constant = 200
            self.superview?.layoutIfNeeded()
        }
    }

    func collapse() {
        isExpanded = false
        collapseIcon.text = "+"
        UIView.animate(withDuration: 0.3) {
            self.collapseContainer.alpha = 0
            self.heightConstraint?.constant = 0
            self.superview?.layoutIfNeeded()
        }
    }

    private func setNeedUpdateDetails() {
        switch objectType {
        case .drug:
            if let detailsPage = self.parentViewController as? OccurrenceUpdateViewController<DrugUpdate> {
                detailsPage.needUpdateDetails = true
            }
        case .involved:
            if let detailsPage = self.parentViewController as? OccurrenceUpdateViewController<InvolvedUpdate> {
                detailsPage.needUpdateDetails = true
            }
        case .vehicle:
            if let detailsPage = self.parentViewController as? OccurrenceUpdateViewController<VehicleUpdate> {
                detailsPage.needUpdateDetails = true
            }
        case .weapon:
            if let detailsPage = self.parentViewController as? OccurrenceUpdateViewController<WeaponUpdate> {
                detailsPage.needUpdateDetails = true
            }
        }
    }

    private func removeNatureFromObject(idVersion: IdVersion, completion: @escaping (Error?) -> Void) {
        if forInsert {
            completion(nil)
        } else {
            switch objectType {
            case .drug:
                let drugDelete = DrugDelete(externalId: nil,
                                            teamId: teamId,
                                            drugs: [idVersion])
                occurrenceService.delete(occurrenceId: occurrenceId, drug: drugDelete, completion: completion)
            case .involved:
                let involvedDelete = InvolvedDelete(externalId: nil,
                                                    teamId: teamId,
                                                    involved: [idVersion])
                occurrenceService.delete(occurrenceId: occurrenceId, involved: involvedDelete, completion: completion)
            case .vehicle:
                let vehicleDelete = VehicleDelete(externalId: nil,
                                                  teamId: teamId,
                                                  vehicles: [idVersion])
                occurrenceService.delete(occurrenceId: occurrenceId, vehicle: vehicleDelete, completion: completion)
            case .weapon:
                let weaponDelete = WeaponDelete(externalId: nil,
                                                teamId: teamId,
                                                weapons: [idVersion])
                occurrenceService.delete(occurrenceId: occurrenceId, weapon: weaponDelete, completion: completion)
            }
        }
    }

    private func didRemoveANature(removedTag: SelectedTag<NaturesVersion>, completion: @escaping (Bool) -> Void) {
        startLoading()
        let idVersion = IdVersion(id: removedTag.value.id, version: removedTag.value.version)
        removeNatureFromObject(idVersion: idVersion) { error in
            garanteeMainThread {
                self.endLoading()
                if let error = error as NSError? {
                    if self.parentViewController.isUnauthorized(error) {
                        if self.parentViewController.isModal {
                            self.parentViewController.dismiss(animated: true) {
                                NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                            }
                        } else {
                            NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                        }
                        return
                    }
                    completion(false)
                    Toast.present(in: self.parentViewController, message: error.domain)
                } else {
                    self.setNeedUpdateDetails()
                    completion(true)
                    self.selectedNatures.remove(removedTag.value)
                    UIView.animate(withDuration: 0.3) {
                        self.superview?.layoutIfNeeded()
                    }
                }
            }
        }
    }

    @objc private func didTapOnHeader() {
        if isExpanded { collapse() }
        else { expand() }
    }

    private func getNatureSelectedTags() -> [SelectedTag<NaturesVersion>] {
        Array(selectedNatures)
            .map { objectNature -> SelectedTag<NaturesVersion>? in
                let label = objectNature.situation.map { "\(objectNature.nature) | \($0)" } ?? objectNature.nature
                return (label: label, value: objectNature)
            }
            .compactMap { $0 }
    }

    private func addNatureToObject(occurrenceId: UUID,
                                   objectNature: OccurrenceObjectNature,
                                   completion: @escaping (Result<IdVersion, Error>) -> Void) {
        if forInsert {
            completion(.success(IdVersion(id: objectNature.natureId, version: 0)))
        } else {
            dataSource.addNatureToObject(occurrenceId: occurrenceId, nature: objectNature) { result in
                garanteeMainThread {
                    self.endLoading()
                    switch result {
                    case .success(let idsVersions):
                        guard let idVersion = idsVersions.first else {
                            completion(.failure(NSError(domain: "Resposta vazia do servidor.", code: 0, userInfo: nil)))
                            return
                        }
                        completion(.success(idVersion))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func addNature(natureId: UUID, nature: Nature, isNew: Bool = false) {
        let situationId = dataSource.selectedObjectData
        let situation = situationId.flatMap { dataSource.getObjectDataBy(id: $0) }?.label
        let objectNature = OccurrenceObjectNature(natureId: natureId, situationId: situationId)

        addNatureToObject(occurrenceId: occurrenceId, objectNature: objectNature) { result in
            garanteeMainThread {
                self.endLoading()
                switch result {
                case .success(let idVersion):
                    let natureVersion = NaturesVersion(id: idVersion.id, version: idVersion.version, nature: nature.name, situation: situation)
                    if isNew {
                        self.selectedNewNatures.append(natureVersion)
                    }
                    self.selectedNatures.insert(natureVersion)
                    let tags = self.getNatureSelectedTags()
                    self.naturesTags.update(with: tags)
                    self.naturesField.clear()
                    self.situationsField.clear()
                    self.situationsField.getSubject()?.send(nil)
                    UIView.animate(withDuration: 0.3, delay: 0.1, options: []) {
                        self.superview?.layoutIfNeeded()
                    }
                case .failure(let error as NSError):
                    if self.parentViewController.isUnauthorized(error) {
                        NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                        return
                    }

                    Toast.present(in: self.parentViewController, message: error.domain)
                }
            }
        }
    }

    internal func addNewNaturesToOccurrence(completion: @escaping () -> Void) {
        guard let currentNature = selectedNewNatures.popLast() else {
            garanteeMainThread {
                self.endLoading()
            }
            completion()
            return
        }
        let natureUpdate = NatureUpdate(natureId: currentNature.id, teamId: teamId)
        occurrenceService.addNature(occurrenceId: occurrenceId, nature: natureUpdate) { error in
            if let error = error as NSError? {
                if self.parentViewController.isUnauthorized(error) {
                    NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                    return
                }

                garanteeMainThread {
                    Toast.present(in: self.parentViewController, message: error.domain)
                }
            } else {
                self.addNewNaturesToOccurrence(completion: completion)
            }
        }
    }

    @objc private func didTapOnAddButton() {
        guard let natureId = dataSource.selectedNature,
              let nature = dataSource.getNatureBy(id: natureId),
              let teamId = cadService.getActiveTeam()?.id else { return }

        startLoading()
        if isSelectedNatureNew {
            if forInsert {
                self.occurrenceNatures.append(nature)
                self.addNature(natureId: natureId, nature: nature, isNew: isSelectedNatureNew)
            } else {
                let natureUpdate = NatureUpdate(natureId: natureId, teamId: teamId)
                occurrenceService.addNature(occurrenceId: occurrenceId, nature: natureUpdate) { error in
                    garanteeMainThread {
                        if let error = error as NSError? {
                            if self.parentViewController.isUnauthorized(error) {
                                NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                                return
                            }
                            Toast.present(in: self.parentViewController, message: error.domain)
                        } else {
                            self.occurrenceNatures.append(nature)
                            self.addNature(natureId: natureId, nature: nature)
                        }
                    }
                }
            }
        } else {
            self.addNature(natureId: natureId, nature: nature)
        }
    }

    private func startLoading() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }

    private func endLoading() {
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnHeader))
        collapseHeader.addGestureRecognizer(tapGesture)

        situationsField.enableAutoLayout()
        naturesField.enableAutoLayout()
        addSubview(collapseContainer)
        collapseContainer.addSubview(naturesField)
        collapseContainer.addSubview(situationsField)
        collapseContainer.addSubview(addButton)
        addSubview(naturesTags)
        collapseContainer.clipsToBounds = true
        addButton.isUserInteractionEnabled = true

        addSubview(collapseHeader)
        collapseHeader.addSubview(titleLabel)
        collapseHeader.addSubview(collapseIcon)

        addSubview(loadingIndicator)
        setupLayout()
    }

    private func setupLayout() {
        collapseHeader.height(35)
        collapseIcon.width(20)
        addButton.height(35)

        heightConstraint = collapseContainer.heightAnchor.constraint(equalToConstant: 200)
        heightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            collapseHeader.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            collapseHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            collapseHeader.trailingAnchor.constraint(equalTo: trailingAnchor),

            collapseContainer.topAnchor.constraint(equalTo: collapseHeader.bottomAnchor, constant: 10),
            collapseContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            collapseContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleLabel.centerYAnchor.constraint(equalTo: collapseHeader.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: collapseIcon.leadingAnchor, constant: -10),

            collapseIcon.centerYAnchor.constraint(equalTo: collapseHeader.centerYAnchor),
            collapseIcon.trailingAnchor.constraint(equalTo: collapseHeader.trailingAnchor),

            naturesField.topAnchor.constraint(equalTo: collapseContainer.topAnchor),
            naturesField.leadingAnchor.constraint(equalTo: collapseContainer.leadingAnchor),
            naturesField.trailingAnchor.constraint(equalTo: collapseContainer.trailingAnchor),

            situationsField.topAnchor.constraint(equalTo: naturesField.bottomAnchor, constant: 10),
            situationsField.leadingAnchor.constraint(equalTo: collapseContainer.leadingAnchor),
            situationsField.trailingAnchor.constraint(equalTo: collapseContainer.trailingAnchor),

            addButton.topAnchor.constraint(equalTo: situationsField.bottomAnchor, constant: 15),
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor),

            naturesTags.topAnchor.constraint(equalTo: collapseContainer.bottomAnchor),
            naturesTags.leadingAnchor.constraint(equalTo: leadingAnchor),
            naturesTags.trailingAnchor.constraint(equalTo: trailingAnchor),
            naturesTags.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingIndicator.topAnchor.constraint(equalTo: topAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
