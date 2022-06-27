//
//  placeTypePickerDataSource.swift
//  CAD
//
//  Created by Samir Chaves on 11/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

import UIKit
import CoreData
import Logger

public protocol PlaceTypeDataSourceDelegate: class {
    func didSelect(placeType: PlaceType)
}

public class PlaceTypePickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    public weak var delegate: PlaceTypeDataSourceDelegate?

    @CadServiceInject
    private var service: CadService

    lazy var logger = Logger.forClass(Self.self)
    private var placeTypes = [PlaceType]()

    public override init() {
        super.init()
    }

    public func setPlaceTypes(_ placeTypes: [PlaceType]) {
        self.placeTypes = placeTypes
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return placeTypes.count + 1
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        }
        return placeTypes[row - 1].description
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            delegate?.didSelect(
                placeType: PlaceType(code: "", description: "")
            )
            return
        }

        delegate?.didSelect(placeType: placeTypes[row - 1])
    }
}
