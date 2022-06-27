//
//  Stack.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

struct Stack<Element: Equatable> {
    fileprivate var array: [Element] = []
    fileprivate var limit: Int

    init(limit: Int = Int.max) {
        self.limit = limit
    }

    mutating func push(_ element: Element) {
        array.removeAll(where: { $0 == element })
        array.insert(element, at: 0)
        if count > limit { pop() }
    }

    mutating func insert(_ element: Element, at index: Int) {
        array.removeAll(where: { $0 == element })
        array.insert(element, at: index)
        if count > limit { pop() }
    }

    @discardableResult
    mutating func pop() -> Element? {
        return array.popLast()
    }

    func peek() -> Element? {
        return array.last
    }

    var count: Int {
        return array.count
    }

    func filter(_ isIncluded: (Element) throws -> Bool ) rethrows -> [Element] {
        return try array.filter(isIncluded)
    }

    subscript (index: Int) -> Element {
        return array[index]
    }

    mutating func clear() {
        array.removeAll()
    }

    mutating func remove(at index: Int) {
        array.remove(at: index)
    }

    func all() -> [Element] {
        return array.map({$0})
    }

    var isEmpty: Bool {
        return array.isEmpty
    }
}
