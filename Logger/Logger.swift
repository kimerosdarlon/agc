//
//  Logger.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 08/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import SwiftyBeaver

public class Logger {

    private let className: String
    private static var destinations = [Destination]()
    public let dateParam = "$date"
    public let classParam = "$class"
    public let methodParam = "$method"
    public let lineParam = "$line"
    public let columnParam = "$column"
    public let messageParam = "$message"
    public var formatter: String
    public var dateTimeStyle = "yyyy-MM-dd HH:mm"

    private init(className: String) {
        self.className = className
        formatter = "[\(dateParam)] - [\(classParam):\(methodParam)] [\(lineParam):\(columnParam)] \(messageParam)"
    }

    public static func forClass(_ clazz: Any.Type) -> Logger {
        let logger = Logger(className: String(describing: clazz.self))
        return logger
    }

    public static func addDestination(destination: Destination) {
        Logger.destinations.append(destination)
    }

    fileprivate func getMessage(_ function: String, _ line: Int, _ column: Int, _ args: CVarArg) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = self.dateTimeStyle
        return formatter.replacingOccurrences(of: classParam, with: className)
            .replacingOccurrences(of: methodParam, with: function)
            .replacingOccurrences(of: lineParam, with: "\(line)")
            .replacingOccurrences(of: columnParam, with: "\(column)")
            .replacingOccurrences(of: messageParam, with: String.init(format: "%@", args))
            .replacingOccurrences(of: dateParam, with: dateformatter.string(from: Date()) )
    }

    public func info( _ args: CVarArg, function: String = #function, line: Int = #line, column: Int = #column ) {
        let message = getMessage(function, line, column, args)
        for destination in Logger.destinations where destination.level.rawValue <= LoggerLevel.info.rawValue {
            destination.send(message: "🔵 INFO: \(message)", level: .info)
        }
    }

    public func error( _ args: CVarArg, function: String = #function, line: Int = #line, column: Int = #column ) {
        let message = getMessage(function, line, column, args)
        for destination in Logger.destinations where destination.level.rawValue <= LoggerLevel.error.rawValue {
            destination.send(message: "🛑 ERROR: \(message)", level: .error)
        }
    }

    public func warning( _ args: CVarArg, function: String = #function, line: Int = #line, column: Int = #column ) {
        let message = getMessage(function, line, column, args)
        for destination in Logger.destinations where destination.level.rawValue <= LoggerLevel.warning.rawValue {
            destination.send(message: "⚠️ WARNING: \(message)", level: .warning)
        }
    }

    public func debug( _ args: CVarArg, function: String = #function, line: Int = #line, column: Int = #column ) {
        let message = getMessage(function, line, column, args)
        for destination in Logger.destinations where destination.level.rawValue <= LoggerLevel.debug.rawValue {
            destination.send(message: "✳️ DEBUG: \(message)", level: .debug)
        }
    }
}
