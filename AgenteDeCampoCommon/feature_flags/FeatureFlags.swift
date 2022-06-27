//
//  FeatureFlags.swift
//  RestClient
//
//  Created by Ramires Moreira on 18/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct FeatureFlags {
    #if DEBUG
        public static let cadModule = true
        public static let cadOccurrencesModule = true
        public static let mockCadModule = false
        public static let mockTeam = false
    #else
        public static let cadModule = true
        public static let cadOccurrencesModule = true
        public static let mockCadModule = false
        public static let mockTeam = false
    #endif
}
