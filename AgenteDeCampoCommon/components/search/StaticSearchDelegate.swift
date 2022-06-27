//
//  StaticSearchDelegate.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 21/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public protocol StaticSearchViewDelegate: class {
    func didSelectResultItem(_ selectedResult: SearchResult)
}
