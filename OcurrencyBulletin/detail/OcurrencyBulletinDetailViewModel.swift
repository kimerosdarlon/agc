//
//  OcurrencyBulletinDetailViewModel.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon

class OcurrencyBulletinDetailViewModel: Hashable {

    static func == (lhs: OcurrencyBulletinDetailViewModel, rhs: OcurrencyBulletinDetailViewModel) -> Bool {
        lhs.details.id == rhs.details.id
    }

    private let details: BulletinDetails
    var codeState: String { details.codeState }
    var codeNational: String { details.codeNational }
    var endDateTime: String { "Fim: \(getFormatedDateTime(dateTimeStr: details.endDateTime))"}
    var hasEndDateTime: Bool { details.endDateTime != nil }
    var isDateApproximated: Bool { details.isDateApproximated }
    var isTimeApproximated: Bool { details.isTimeApproximated }
    var nature: [String] { details.natures }
    var registryDateTime: String { getFormatedDateTime(dateTimeStr: details.registryDateTime) }
    var registryPoliceStation: String { details.registryPoliceStation ?? "---"}
    var responsiblePoliceStation: String { details.responsiblePoliceStation ?? "---"}
    var hasResponsiblePoliceStation: Bool { details.responsiblePoliceStation != nil }
    var startDateTime: String { "Início: \(getFormatedDateTime(dateTimeStr: details.startDateTime))" }
    var hasStartDateTime: Bool { details.startDateTime != nil }
    var hasStory: Bool { details.story != nil }
    var story: String { details.story ?? "---" }
    var involveds: [PersonInvolvedDetail] { details.peopleInvolved }
    let emptyMessage = "---"
    var vehicles: [VehicleBulletim] { details.objects.vehicles }
    var weapons: [Weapons] { details.objects.weapons }
    var cellphones: [Cellphones] { details.objects.cellphones }
    var others: [BulletinGenericObject] { details.objects.others }
    var documents: [Documents] { details.objects.documents ?? [] }
    var drugs: [Drugs] { details.objects.drugs ?? [] }

    var address: String {
        return formatedAddress(addrress: details.address)
    }

    private var dateFormatterReader: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone.current
        return formatter
    }

    private var dateFormatterWriter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy 'ás' HH:mm"
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone.current
        return formatter
    }

    init(details: BulletinDetails) {
        self.details = details
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(details.id)
    }

    private func getFormatedDateTime(dateTimeStr: String? ) -> String {
        guard let dateTime = dateTimeStr else { return "---" }
        guard let date = dateFormatterReader.date(from: dateTime) else { return "---"}
        return dateFormatterWriter.string(from: date)
    }

    func getName(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.name)
    }

    func getSocialName(_ involved: PersonInvolvedDetail ) -> String {
        return string(for: involved.socialName)
    }

    func getCompanyName(_ involved: PersonInvolvedDetail ) -> String {
        return string(for: involved.companyName)
    }

    func getNickName(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.nickname)
    }

    func getMotherName(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.motherName)
    }

    func getFatherName(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.fatherName)
    }

    func getSexualOrientation(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.sexualOrientation)
    }

    func getGender(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.genderIdentity)
    }

    func getNationality(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.nationality)
    }

    func getJob(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.businessLine)
    }

    func getAddress(_ involved: PersonInvolvedDetail) -> String {
        if let address = involved.address {
            return formatedAddress(addrress: address)
        }
        return emptyMessage
    }

    private func formatedAddress( addrress: Address ) -> String {
        let complement = addrress.complement ?? ""
        let reference = addrress.reference ?? ""
        let street = (addrress.street ?? "") + "\(complement) \(reference)"
        var district = addrress.district ?? ""
        if !district.isEmpty {
            district = " - \(district), "
        }
        var city = addrress.city ?? ""
        var state = addrress.state ?? ""
        if !city.isEmpty {
            city = "\(city) - "
        }
        if !state.isEmpty {
            state = "\(state)"
        }
        return street + district + city + state
    }

    func documentNumber(_ document: String? ) -> String {
        guard let document = document, !document.isEmpty else { return emptyMessage }
        if document.isCPF || document.isCNPJ {
            return document.applyCpfORCnpjMask
        }
        return document
    }

    func getCPF(_ involved: PersonInvolvedDetail) -> String {
        guard let cpf = involved.cpf else { return emptyMessage }
        if cpf.isCPF {
            return cpf.applyCpfORCnpjMask
        }
        return "Inválido \(cpf)"
    }

    func getCPF(_ owner: Owner? ) -> String {
        guard let cpf = owner?.cpf else { return emptyMessage }
        if cpf.isCPF {
            return cpf.applyCpfORCnpjMask
        }
        return "Inválido \(cpf)"
    }

    func getCNPJ(_ involved: PersonInvolvedDetail) -> String {
        guard let cnpj = involved.cnpj else { return emptyMessage }
        if cnpj.isCNPJ {
            return cnpj.applyCpfORCnpjMask
        }
        return "Inválido \(cnpj)"
    }

    func string(for value: String? ) -> String {
        if let finalValue = value, !finalValue.isEmpty {
            return finalValue
        }
        return emptyMessage
    }

    func getAge(_ involved: PersonInvolvedDetail) -> String {
        if let birthDateStr = involved.birthDate {
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let birthDate = dateFormatter.date(from: birthDateStr) {
                let calendar = Calendar.init(identifier: .gregorian)
                let years = calendar.dateComponents([.year], from: birthDate, to: today).year ?? 0
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let dateStr = dateFormatter.string(from: birthDate)
                return "\(dateStr) - \(years) Anos"
            }
        }
        return emptyMessage
    }

    func getRepresentative(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.representative)
    }

    func getBusinessLine(_ involved: PersonInvolvedDetail) -> String {
        return string(for: involved.businessLine)
    }

    func plate(for vehicle: VehicleBulletim) -> String {
        if let plate = vehicle.plate {
            return plate.apply(pattern: AppMask.plateMask, replacmentCharacter: "#")
        }
        return emptyMessage
    }

    func phoneHeader(phone: Cellphones) -> String {
        let model = phone.model ?? ""
        let brand = phone.brand ?? ""
        let pipe = brand.isEmpty ? "" : " | "
        let header = brand + pipe + model
        return string(for: header)
    }
}
