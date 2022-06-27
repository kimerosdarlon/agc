//
//  Checklist.swift
//  CAD
//
//  Created by Ramires Moreira on 25/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct ReplyForm: Codable {
    public let team: UUID
    public let responses: [Response]
}

public enum AnswerValue: Codable {
    case quantitative(Float), textual(String), binary(Bool), multipleChoice([Int]), singleChoice(Int)

    public init(from decoder: Decoder) throws {
        if let float = try? decoder.singleValueContainer().decode(Float.self) {
            self = .quantitative(float)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .textual(string)
            return
        }

        if let bool = try? decoder.singleValueContainer().decode(Bool.self) {
            self = .binary(bool)
            return
        }

        if let intList = try? decoder.singleValueContainer().decode(Array<Int>.self) {
            self = .multipleChoice(intList)
            return
        }

        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .singleChoice(int)
            return
        }

        throw AnswerError.missingValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .quantitative(let float):
            try container.encode(float)
        case .binary(let bool):
            try container.encode(bool)
        case .multipleChoice(let intList):
            try container.encode(intList)
        case .singleChoice(let int):
            try container.encode(int)
        case .textual(let string):
            try container.encode(string)
        }
    }

    enum AnswerError: Error {
        case missingValue
    }
}

public struct Response: Codable {
    public let question: Int
    public let answer: AnswerValue?
    public let justificative: String?

    public func isAcceptable() -> Bool {
        switch answer {
        case .binary(let answer):
            if answer == true {
                return true
            }
        case .textual(let answer):
            if !answer.trimmingCharacters(in: .whitespaces).isEmpty {
                return true
            }
        case .multipleChoice(let answer):
            if answer.count > 0 {
                return true
            }
        case .singleChoice(let answer):
            return answer >= 0
        case .quantitative(let answer):
            return !answer.isNaN
        default:
            if let justificative = justificative, !justificative.trimmingCharacters(in: .whitespaces).isEmpty {
                return true
            }
        }

        return false
    }
}

public enum QuestionType: String {
    case quantitative = "q"
    case binary = "b"
    case textual = "t"
    case multipleChoice = "m"
    case singleChoice = "s"
}

extension QuestionType: Codable {
    enum Key: CodingKey {
        case rawValue
    }

    enum CodingError: Error {
        case unknownValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "q":
            self = .quantitative
        case "b":
            self = .binary
        case "t":
            self = .textual
        case "m":
            self = .multipleChoice
        case "s":
            self = .singleChoice
        default:
            throw CodingError.unknownValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .quantitative:
            try container.encode("q")
        case .binary:
            try container.encode("b")
        case .multipleChoice:
            try container.encode("m")
        case .textual:
            try container.encode("t")
        case .singleChoice:
            try container.encode("s")
        }
    }
}

public struct Checklist: Codable {
    public let questions: [Question]
}

public struct Question: Codable {
    public let id: Int
    public let text: String
    public let type: QuestionType
    public let alternatives: [Alternative]?
    public let checklist: Int
}

public struct Alternative: Codable {
    public let value: Int
    public let text: String
}
