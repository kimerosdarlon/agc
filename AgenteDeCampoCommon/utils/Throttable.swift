//
//  Throttable.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 15/10/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public class Throttable {
    private let delay: TimeInterval
    private let queue: DispatchQueue
    private var workItem: DispatchWorkItem?

    public var handler: (() -> Void)?

    public init(delay: TimeInterval, in queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    public func perform() {
        if let handler = handler {
            workItem?.cancel()
            workItem = DispatchWorkItem(block: handler)
            queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
        }
    }
}
