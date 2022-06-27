//
//  Recent.swift
//  CoreDataModels
//
//  Created by Ramires Moreira on 15/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct Recent {
    public let text: String
    public let textExpanded: String
    public let module: String
    public var iconName: String
    public var date: Date
    public var searchString: [String: Any]?

    public init (text: String, textExpanded: String, module: String, iconName: String = "clock", date: Date = Date(), searchString: [String: Any]? ) {
        self.text = text
        self.module = module
        self.iconName = iconName
        self.date = date
        self.searchString = searchString
        self.textExpanded = textExpanded
    }
}
