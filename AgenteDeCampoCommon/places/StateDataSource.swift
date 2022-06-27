//
//  StateDataSource.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 20/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import Logger

public protocol StateDataSourceDelegate: class {
    func didSelect(state: State)
}

public class StateDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    public weak var delegate: StateDataSourceDelegate?
    public var results = [State]()
    lazy var logger = Logger.forClass(Self.self)

    @PlacesServiceInject
    internal var placesService: PlacesService

    public override init() {
        super.init()
        self.results = placesService.getStates()
            .sorted(by: { $0.name.compare($1.name) == .orderedAscending })
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        results.count + 1
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        }
        return results[row - 1].name
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            delegate?.didSelect(state: State.empty)
            return
        }
        let state = results[row - 1]
        delegate?.didSelect(state: state)
    }

    public func findByInitials(_ initials: String) -> State? {
        results.first(where: { $0.initials == initials })
    }

    public func setBulletinState(for delegate: StateDataSourceDelegate, withinitials initials: String? ) {
        guard let stateInicial = initials else { return }
        if let state = findByInitials(stateInicial) {
            delegate.didSelect(state: state)
        }
    }
}
