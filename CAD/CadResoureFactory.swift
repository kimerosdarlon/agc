//
//  CadResoureFactory.swift
//  CAD
//
//  Created by Ramires Moreira on 10/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

class CadResoureFactory {

    static func mockPerson(_ agency: Agency) -> Person {
        return Person(agency: agency, role: "Cabo", cpf: "03829907303",
                      registration: "100005", name: "Ramires do Nascimento Moreira",
                      functionalName: "Ramires",
                      cellphone: "88888888888", telephone: nil, id: .init())
    }

    fileprivate static func mockAgency() -> Agency {
        return Agency(name: "Polícia Militar do Acre", initials: "PM AC", id: "123123123")
    }

    fileprivate static func mockEquipament(_ agency: Agency) -> [Equipment] {
        return [
            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Carro", id: .init()), id: .init()),
            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Carro", id: .init()), id: .init()),
            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Carro", id: .init()), id: .init()),

            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Moto", id: .init()), id: .init()),
            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Moto", id: .init()), id: .init()),

            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Pistola", id: .init()), id: .init()),
            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Pistola", id: .init()), id: .init()),
            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Pistola", id: .init()), id: .init()),
            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Pistola", id: .init()), id: .init()),

            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Cachorro", id: .init()), id: .init()),
            Equipment(agency: agency, kmAllowed: true, km: 12300, groupEquipment: nil, brand: "Chevrolet", model: "Corsa",
                      plate: "HXR-6821", prefix: "", type: .init(name: "Cachorro", id: .init()), id: .init())
        ]
    }

    static func mockTeamPerson() -> [TeamPerson] {
        var person1 = mockPerson(mockAgency())
        person1.id = .init()
        person1.role = "Sargento"
        person1.name = "Antônio Castro Alves"
        var person2 = mockPerson(mockAgency())
        person2.id = .init()
        person2.name = "Sara Almirante Castro"
        person2.role = "Cabo"
        var person3 = mockPerson(mockAgency())
        person3.id = .init()
        person3.name = "Anderson Costa Neves"
        person3.role = "Tenente"
        let teamPerson = [
            TeamPerson(role: Role(name: "Sargento", id: .init()), person: person1),
            TeamPerson(role: Role(name: "Cabo", id: .init()), person: person2),
            TeamPerson(role: Role(name: "Tenente", id: .init()), person: person3)
        ]
        return teamPerson
    }

    fileprivate static func mockRegions() -> [OperatingRegion] {
        return [
            OperatingRegion(description: "1º BPM/BPC/CENTRO",
                            name: "1º BPM/BPC/CENTRO", initials: "BPM", id: .init(), agency: mockAgency()),
            OperatingRegion(description: "2º BPM/BPC/CENTRO",
                            name: "2º BPM/BPC/CENTRO", initials: "2 - BPM", id: .init(), agency: mockAgency()),
            OperatingRegion(description: "3º BPM/BPC/CENTRO",
                            name: "3º BPM/BPC/CENTRO", initials: "BPM", id: .init(), agency: mockAgency()),
            OperatingRegion(description: "4º BPM/BPC/CENTRO",
                            name: "4º BPM/BPC/CENTRO", initials: "2 - BPM", id: .init(), agency: mockAgency()),
            OperatingRegion(description: "5º BPM/BPC/CENTRO",
                            name: "5º BPM/BPC/CENTRO", initials: "BPM", id: .init(), agency: mockAgency()),
            OperatingRegion(description: "6º BPM/BPC/CENTRO",
                            name: "6º BPM/BPC/CENTRO", initials: "2 - BPM", id: .init(), agency: mockAgency())
        ]
    }

    static func mockTeam() -> Team {
        let agency = mockAgency()
        let equipments = mockEquipament(agency)
        let regions = mockRegions()
        let teamPerson = mockTeamPerson()
        let team = Team(expectedEndDateTime: "2020-04-05T08:00",
                        expectedStartDateTime: "2020-04-04T22:30",
                        equipments: equipments, teamPeople: teamPerson,
                        timeZone: "BRT", endReason: "acabou", mixed: true, name: "Equipe Noturna",
                        operatingRegions: regions, situation: "Ativa", phone: "88888888888", id: .init())
        return team
    }

    static func mockResource() -> CadResource {
        let person = mockPerson(mockAgency())
        let team = mockTeam()
        let profile = PersonProfile(person: person, activeTeam: team.id, teams: [team])
        let resource = CadResource(resource: profile, cadToken: "token", dispatches: [])
        return resource
    }
}
