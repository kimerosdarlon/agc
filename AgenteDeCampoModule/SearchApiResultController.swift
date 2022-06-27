//
//  SearchApiResultController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public protocol SearchApiResultController where Self: UIViewController {

    init(search params: [String: Any], userInfo: [String: String], isFromSearch: Bool)
}
