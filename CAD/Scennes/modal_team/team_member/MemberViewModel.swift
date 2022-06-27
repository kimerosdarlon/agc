//
//  MemberViewModel.swift
//  CAD
//
//  Created by Ramires Moreira on 08/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class MemberViewModel {
    static let defaultImage = UIImage(named: "roundedUser")

    private let member: TeamPerson

    var image: UIImage = {
        return MemberViewModel.defaultImage!
    }()

    var name: String {
        return member.person.functionalName
    }

    var role: String {
        return member.role.name
    }

    var responsibility: String {
        return member.person.role
    }

    var cellphone: String? {
        return member.person.cellphone
    }

    var telephone: String? {
        return member.person.telephone
    }

    var agency: Agency {
        return member.person.agency
    }

    var fullname: String {
        return member.person.name
    }

    var registration: String {
        return member.person.registration
    }

    init(member: TeamPerson) {
        self.member = member
    }
}
