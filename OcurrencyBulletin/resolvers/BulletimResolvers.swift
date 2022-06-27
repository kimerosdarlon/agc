//
//  BulletimResolvers.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 16/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon

struct CPFResolver: SearchTextResolver {
    var next: SearchTextResolver?

    func resolveSearch(text: String) -> [String: Any] {
        if text.isCPF {
            return ["cpf": text.onlyNumbers(), "service": ServiceType.physical.rawValue]
        }
        return next?.resolveSearch(text: text) ?? [:]
    }

    func resolveInfo(text: String) -> [String: String] {
        if text.isCPF {
            return ["CPF": text.onlyNumbers().apply(pattern: AppMask.cpfMask, replacmentCharacter: "#")]
        }
        return next?.resolveInfo(text: text) ?? [:]
    }
}

struct CNPJResolver: SearchTextResolver {
    var next: SearchTextResolver?

    func resolveSearch(text: String) -> [String: Any] {
        if text.isCNPJ {
            return ["cnpj": text.onlyNumbers(), "service": ServiceType.legal.rawValue]
        }
        return next?.resolveSearch(text: text) ?? [:]
    }

    func resolveInfo(text: String) -> [String: String] {
        if text.isCNPJ {
            return ["CNPJ": text.onlyNumbers().apply(pattern: AppMask.cnpjMask, replacmentCharacter: "#")]
        }
        return next?.resolveInfo(text: text) ?? [:]
    }
}

struct CodNacionalResolver: SearchTextResolver {
    var next: SearchTextResolver?

    func resolveSearch(text: String) -> [String: Any] {
        if text.matches(in: AppRegex.codeNationalPattern) {
            return [
                "nationalCode": text.onlyNumbers().apply(pattern: AppMask.codeNational, replacmentCharacter: "#"),
                "service": ServiceType.national.rawValue
            ]
        }
        return next?.resolveSearch(text: text) ?? [:]
    }

    func resolveInfo(text: String) -> [String: String] {
        if text.matches(in: AppRegex.codeNationalPattern) {
            return [
                "Cod. Nacional": text.onlyNumbers().apply(pattern: AppMask.codeNational, replacmentCharacter: "#")
            ]
        }
        return next?.resolveInfo(text: text) ?? [:]
    }
}

struct PlateResolver: SearchTextResolver {
    var next: SearchTextResolver?

    func resolveSearch(text: String) -> [String: Any] {
        if text.matches(inAny: AppRegex.platePatterns) {
            return [
                "plate": text.onlyStandardCharacters(),
                "service": ServiceType.vehicle.rawValue
            ]
        }
        return next?.resolveSearch(text: text) ?? [:]
    }

    func resolveInfo(text: String) -> [String: String] {
        if text.matches(inAny: AppRegex.platePatterns) {
            return ["Placa": text.onlyStandardCharacters().apply(pattern: AppMask.plateMask, replacmentCharacter: "#")]
        }
        return next?.resolveInfo(text: text) ?? [:]
    }
}

struct ChassiResolver: SearchTextResolver {

    var next: SearchTextResolver?

    func resolveSearch(text: String) -> [String: Any] {
        if text.matches(in: AppRegex.chassiPattern) {
            return [
                "chassis": text.onlyStandardCharacters(),
                "service": ServiceType.vehicle.rawValue
            ]
        }
        return next?.resolveSearch(text: text) ?? [:]
    }

    func resolveInfo(text: String) -> [String: String] {
        if text.matches(in: AppRegex.chassiPattern) {
            return [ "Chassi": text.onlyStandardCharacters() ]
        }
        return next?.resolveInfo(text: text) ?? [:]
    }
}

struct PersonNameResolver: SearchTextResolver {
    var next: SearchTextResolver?

    func resolveSearch(text: String) -> [String: Any] {
        if text.prepareForSearch().matches(in: AppRegex.personNamePattern ) {
            return [
                "name": text,
                "service": ServiceType.physical.rawValue
            ]
        }
        return next?.resolveSearch(text: text) ?? [:]
    }

    func resolveInfo(text: String) -> [String: String] {
        if text.matches(in: AppRegex.personNamePattern ) {
            return [ "Nome": text.uppercased() ]
        }
        return next?.resolveInfo(text: text) ?? [:]
    }
}
