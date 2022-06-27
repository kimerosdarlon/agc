//
//  FormValidator.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 29/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

public struct FormValidator {

    public init() {
    }

    public func checkDate(string: Any? ) throws {
        guard let string = string as? String, !string.isEmpty else { return }
        if !string.matches(in: "\\d{2}/\\d{2}/\\d{4}") {
            throw InputValidationError.date
        }
        let formater = DateFormatter()
        formater.dateFormat = "dd/MM/yyyy"
        if formater.date(from: string) == nil {
            throw InputValidationError.invalidDate
        }
    }

    public func checkIsEmpty(key: String?, value: String?, error: ApplicationErrors ) throws {
        if (key != nil && !key!.isEmpty) && (value == nil || value!.isEmpty ) {
            throw NSError(domain: error.message, code: error.code, userInfo: nil)
        }
    }

    public func checkChassis(string: Any? ) throws {
        guard let string = string as? String, !string.isEmpty else { return }
        if !string.matches(in: AppRegex.chassiPattern) {
            let error = InputValidationError.chassis
            throw NSError(domain: error.description, code: 400, userInfo: [:])
        }
    }

    public func checkPlate(string: Any? ) throws {
        if let string = string as? String, !string.isEmpty {
            let std = string.onlyStandardCharacters()
            let platePatterns = AppRegex.platePatterns
            var match = false
            for patern in platePatterns {
                if std.matches(in: patern) {
                    match = true
                    break
                }
            }
            if !match {
                throw InputValidationError.plate
            }
        }
        return
    }

    public func checkCPFAndCnpjInput(string: Any? ) throws {
        if let string = string as? String, !string.isEmpty {
            let std = string.onlyStandardCharacters()
            if std.isCPF || std.isCNPJ {
                return
            }
            if std.count <= 11 {
                throw InputValidationError.cpf
            } else {
                throw InputValidationError.cnpj
            }
        }
        return
    }

    public func checkCnh(string: Any? ) throws {
        if let string = string as? String, !string.isEmpty {
            let std = string.onlyStandardCharacters()
            if std.count == string.count {
                return
            }

            throw InputValidationError.cnh
        }
        return
    }

    public func checkRenach(string: Any? ) throws {
        if let string = string as? String, !string.isEmpty {
            if string.count == 11 {
                return
            }

            throw InputValidationError.renach
        }
        return
    }

    public func checkPid(string: Any? ) throws {
        if let string = string as? String, !string.isEmpty {
            let std = string.onlyNumbers()
            if std == string {
                return
            }

            throw InputValidationError.pid
        }
        return
    }

    public func checkProtocol(string: Any? ) throws {
        if let string = string as? String, !string.isEmpty {
            let std = string.onlyNumbers()
            if 19...36 ~= std.count {
                return
            }

            throw InputValidationError.protocol
        }
        return
    }
}
