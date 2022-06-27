//
//  CityDataSource.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 20/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public protocol CityDataSourceDelegate: class {
    func didSelect(city: City)
}

public class CityDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    @PlacesServiceInject
    internal var placesService: PlacesService

    public var selectadeState: String? {
        didSet {
            cities.removeAll()
            guard let stateInitials = selectadeState, !stateInitials.isEmpty else {
                return
            }

            self.cities = placesService.getCitiesFor(state: stateInitials)
                .sorted(by: {$0.name.compare($1.name) == .orderedAscending})
        }
    }

    public weak var delegate: CityDataSourceDelegate?

    private var cities = [City]()

    public override init() {
        super.init()
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row].name
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelect(city: cities[row] )
    }

    public func findByCode(_ code: String) -> City? {
        if let code = Int(code) {
            return placesService.getCityBy(code: code)
        }
        return nil
    }

    public func setBulletinCity(for delegate: CityDataSourceDelegate, withCode code: String?  ) {
        if let cityCode = code,
           let city = findByCode(cityCode) {
            delegate.didSelect(city: city)
        }
    }
}
