//
//  Sequece+AgenteCampo.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 08/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation

public extension Sequence {
  func sorted(
    by firstPredicate: (Element, Element) -> Bool,
    _ secondPredicate: (Element, Element) -> Bool,
    _ otherPredicates: ((Element, Element) -> Bool)...
  ) -> [Element] {
    return sorted(by:) { lhs, rhs in
      if firstPredicate(lhs, rhs) { return true }
      if firstPredicate(rhs, lhs) { return false }
      if secondPredicate(lhs, rhs) { return true }
      if secondPredicate(rhs, lhs) { return false }
      for predicate in otherPredicates {
        if predicate(lhs, rhs) { return true }
        if predicate(rhs, lhs) { return false }
      }
      return false
    }
  }
}
