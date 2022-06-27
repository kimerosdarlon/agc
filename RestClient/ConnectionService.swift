//
//  ConnectionViewController.swift
//  InsightLabChallenge
//
//  Created by Ramires Moreira on 09/03/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import SystemConfiguration

enum ConnectionType: String {
    case wifi = "wifi"
    case mobile = "mobile"
    case none = "sem conexão"
}

class ConnectionService: NSObject {

    private let reachability: SCNetworkReachability
    private(set) var connectionType: ConnectionType = .none

    init(host: String) {
        self.reachability = SCNetworkReachabilityCreateWithName(nil, host)!
    }

    public func checkConnection() -> ConnectionType {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        if isNetworkReach(with: flags) {
            if flags.contains(.isWWAN) {
                self.connectionType = .mobile
            } else {
                self.connectionType = .wifi
            }
        } else {
            self.connectionType = .none
        }
        return self.connectionType
    }

    fileprivate func isNetworkReach(with flags: SCNetworkReachabilityFlags ) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectionAutomaticaly = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnetcWithoutUserInteraction = canConnectionAutomaticaly && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnetcWithoutUserInteraction)
    }
}
