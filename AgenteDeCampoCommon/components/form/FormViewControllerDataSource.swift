//
//  FormViewControllerDataSource.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 11/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public protocol FormViewControllerDataSource: class {
    associatedtype Model: ModelForm
    func textFieldForm(for position: Int) -> CustomTextFieldFormBindable<Model.Entity>
    func numberOfTextFields() -> Int
    func didReturnBehaviorRelay() -> BehaviorRelay<Model>
    func isUniqueParameter( textField: CustomTextFieldFormBindable<Model.Entity> ) -> Bool
    func shouldRemove(textField: CustomTextFieldFormBindable<Model.Entity> ) -> Bool
    func rightButtonText() -> String
    func leftButtonText() -> String
}
