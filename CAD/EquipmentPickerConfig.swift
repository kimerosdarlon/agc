//
//  EquipmentPickerSetting.swift
//  CAD
//
//  Created by Samir Chaves on 07/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

public class EquipmentPickerConfigViewController: EquipmentPickerViewController, SettingsOption, EquipmentPickerDelegate {
    private var hasActiveTeam = false

    public func settingsTitle() -> String {
        "Equipamento em uso"
    }

    public func settingsSubTitle() -> String {
        ""
    }

    public func settingsIcon() -> UIImage {
        UIImage(systemName: "car")!
    }

    public func accesoryView() -> UIView? {
        nil
    }

    public func enabled() -> Bool {
        let equipments = cadService.getActiveTeam()?.equipments ?? []
        return hasActiveTeam && !equipments.isEmpty
    }

    @objc public func setActiveTeam() {
        if let activeTeam = cadService.getActiveTeam() {
            tableView.updateEquipmentsModel(.init(equipments: activeTeam.equipments))
        }
        hasActiveTeam = cadService.hasActiveTeam()
    }

    public init() {
        super.init()
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didSkip() { }

    func didSelect(equipment: Equipment?) {
        navigationController?.popViewController(animated: true)
    }
}
