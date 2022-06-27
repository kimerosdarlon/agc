//
//  SearchDelegate.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public protocol SearchDelegate: class {
    func present(controller: UIViewController, completion: (() -> Void)?  )
}
