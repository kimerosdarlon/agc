//
//  Debouncer.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 12/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public class Debouncer {

    private let timeInterval: TimeInterval
    private var timer: Timer?

    public typealias Handler = () -> Void
    public var handler: Handler?

    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    public func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] (timer) in
            self?.timeIntervalDidFinish(for: timer)
        })
    }

    @objc private func timeIntervalDidFinish(for timer: Timer) {
        guard timer.isValid else {
            return
        }

        handler?()
        handler = nil
    }
}
