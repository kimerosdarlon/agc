//
//  EquipmentPickerViewController.swift
//  CAD
//
//  Created by Samir Chaves on 02/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class EquipmentPickerHeaderView: UIStackView {
    private let titleLabel = UILabel.build(withSize: 18, color: .appTitle, text: "Qual equipamento está utilizando hoje?")
    private let descriptionLabel = UILabel.build(
        withSize: 15, alpha: 0.6, color: .appTitle, text: "Selecione um item entre as listas abaixo"
    )

    override func didMoveToSuperview() {
        alignment = .leading
        axis = .vertical
        spacing = 7
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = .init(top: 15, leading: 15, bottom: 15, trailing: 15)
        distribution = .fillProportionally
        addArrangedSubview(titleLabel)
        addArrangedSubview(descriptionLabel)
    }
}

protocol EquipmentPickerDelegate: class {
    func didSkip()
    func didSelect(equipment: Equipment?)
}

public class EquipmentPickerViewController: UIViewController {
    weak var delegate: EquipmentPickerDelegate?
    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    @CadServiceInject
    internal var cadService: CadService

    internal var tableView: EquipmentPickerTableView!

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Salvar", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .appBlue
        btn.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
        return btn
    }()

    init(equipments: [Equipment]? = nil) {
        super.init(nibName: nil, bundle: nil)
        var finalEquipments = cadService.getActiveTeam()?.equipments ?? []
        if equipments != nil {
            finalEquipments = equipments!
        }
        let equipmentsModel = EquipmentGroupViewModel(equipments: finalEquipments)
        self.tableView = EquipmentPickerTableView(equipmentsViewModel: equipmentsModel).enableAutoLayout()
        title = "Equipamento em uso"
        modalPresentationStyle = .custom

        transitionDelegate = DefaultModalPresentationManager()
        transitioningDelegate = transitionDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didSkip() {
        if isModal {
            dismiss(animated: true, completion: {
                self.delegate?.didSkip()
            })
        } else {
            self.delegate?.didSkip()
        }
    }

    private func storeEquipment() {
        if let equipmentId = tableView.selectedEquipment?.id.uuidString {
            UserDefaults.standard.set(equipmentId, forKey: "currentEquipment")
        } else {
            UserDefaults.standard.set(nil, forKey: "currentEquipment")
        }
    }

    @objc private func didSelect() {
        if tableView.selectedEquipment != nil {
            if isModal {
                dismiss(animated: true, completion: {
                    self.storeEquipment()
                    self.delegate?.didSelect(equipment: self.tableView.selectedEquipment)
                })
            } else {
                self.storeEquipment()
                self.delegate?.didSelect(equipment: tableView.selectedEquipment)
            }
        } else {
            let alert = UIAlertController(title: "Selecione algum equipamento.", message: "Você deve selecionar, ao menos, um equipamento.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground

        let headerView = EquipmentPickerHeaderView(frame: .zero).enableAutoLayout()

        view.addSubview(headerView)
        view.addSubview(sendButton)
        view.addSubview(tableView)
        let safeArea = view.safeAreaLayoutGuide

        headerView.width(tableView).height(100).top(view, mutiplier: 0)

        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1),
            sendButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: sendButton.topAnchor),

            sendButton.heightAnchor.constraint(equalToConstant: 45),
            sendButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0)
        ])

        tableView.apply()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedEquipment = cadService.getStoredEquipment() {
            tableView.selectEquipment(id: selectedEquipment.id)
        }
    }
}
