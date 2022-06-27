//
//  GeneralOccurrenceNaturesUpdate.swift
//  CAD
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import Combine

class GeneralOccurrenceNaturesUpdate: OccurrenceInsertViewController<[Nature]> {

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    @CadServiceInject
    private var cadService: CadService

    private var naturesField: MultiselectorComponent<UUID>!
    private var naturesSubject: CurrentValueSubject<[UUID], Never>?
    private let agencyId: String
    private let occurrenceId: UUID
    private let teamId: UUID
    private var natures = [Nature]()

    init(teamId: UUID, occurrenceId: UUID, agencyId: String, currentNatures: [Nature]) {
        self.agencyId = agencyId
        self.occurrenceId = occurrenceId
        self.teamId = teamId
        super.init(name: "Naturezas")
        naturesField = MultiselectorComponent<UUID>(parentViewController: self,
                                                    label: "Selecione a natureza",
                                                    inputPlaceholder: "")
        naturesSubject = naturesField.getSubject()

        naturesField.onRemoveASelection = { nature, completion in
            let confirmAlert = UIAlertController(
                title: "Confirma a remoção?",
                message: "Ao remover uma natureza da ocorrência os objetivos vinculados a ela serão também removidos. Você tem certeza que deseja continuar?",
                preferredStyle: .alert
            )
            let confirmAction = UIAlertAction(title: "Remover", style: .destructive, handler: { _ in
                self.startLoading()
                self.removeNature(nature.value) { error in
                    garanteeMainThread {
                        self.stopLoading()
                        if let error = error as NSError? {
                            Toast.present(in: self, message: error.domain)
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: { _ in
                completion(false)
            })
            confirmAlert.addAction(confirmAction)
            confirmAlert.addAction(cancelAction)
            self.present(confirmAlert, animated: true)
        }

        naturesField.onSelect = { nature, completion in
            self.startLoading()
            self.addNature(nature.value) { error in
                garanteeMainThread {
                    self.stopLoading()
                    if let error = error as NSError? {
                        Toast.present(in: self, message: error.domain)
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }

        startLoading()
        fetchNatures { error in
            garanteeMainThread {
                self.stopLoading()
                if let error = error as NSError? {
                    Toast.present(in: self, message: error.domain)
                } else {
                    self.setupNaturesField()
                    self.naturesSubject?.send(currentNatures.map { $0.id })
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addNature(_ natureId: UUID, completion: @escaping (Error?) -> Void) {
        occurrenceService.addNature(occurrenceId: occurrenceId,
                                    nature: NatureUpdate(natureId: natureId, teamId: teamId),
                                    completion: completion)
    }

    private func removeNature(_ natureId: UUID, completion: @escaping (Error?) -> Void) {
        occurrenceService.removeNature(occurrenceId: occurrenceId,
                                       natureId: natureId,
                                       teamId: teamId,
                                       completion: completion)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        naturesField.enableAutoLayout()
        container.addSubview(naturesField)

        NSLayoutConstraint.activate([
            naturesField.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            naturesField.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.95),
            naturesField.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            container.bottomAnchor.constraint(equalTo: naturesField.bottomAnchor, constant: 10)
        ])
    }

    private func fetchNatures(completion: @escaping (Error?) -> Void) {
        cadService.getNatures(agencyId: self.agencyId) { result in
            switch result {
            case .success(let natures):
                self.natures = natures
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    internal func searchMatch(query: NSRegularExpression, with term: String) -> NSRange? {
        let foldedTerm = term.prepareForSearch()
        let range = NSRange(location: 0, length: foldedTerm.utf16.count)
        return query.firstMatch(in: foldedTerm, options: [], range: range)?.range
    }

    func setupNaturesField() {
        naturesField?.onChangeQuery = { query, completion in
            guard !query.isEmpty else {
                let results = self.natures.map { DynamicResult(key: $0.id, value: $0.name) }
                completion(results)
                return
            }
            guard let queryRegex = try? NSRegularExpression(pattern: query.prepareForSearch(),
                                                            options: [.caseInsensitive, .ignoreMetacharacters]) else {
                completion([])
                return
            }
            let results = self.natures.filter { item in
                self.searchMatch(query: queryRegex, with: item.name) != nil
            }.map { DynamicResult(key: $0.id, value: $0.name) }

            completion(results)
        }

        naturesField?.resultByKey = { key, completion in
            let result = self.natures.first(where: { $0.id == key }).map {
                DynamicResult(key: $0.id, value: $0.name)
            }
            completion(result)
        }
    }

    override func didSave() {
        updateDelegate?.didSave()
        navigationController?.popViewController(animated: true)
    }
}
