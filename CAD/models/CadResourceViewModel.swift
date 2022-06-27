//
//  CadResourceViewModel.swift
//  CAD
//
//  Created by Ramires Moreira on 07/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

public class CadResourceViewModel {

    private var team: Team
    private var dispatches: [TeamDispatch]

    public init(team: Team, andDispatches dispatches: [TeamDispatch]? = nil) {
        self.team = team
        self.dispatches = dispatches ?? []
    }

    public func getTeam() -> Team {
        return team
    }

    public var teamName: UILabel {
        return UILabel(text: team.name)
            .font(UIFont.robotoMedium.withSize(20))
    }

    public var dates: UILabel? {
        let startDate = team.startDateStr
        let endData = team.endDateStr
        let infix = startDate.isEmpty ? "" : " - "
        let text = " "+startDate + infix + endData
        if text.trimmingCharacters(in: .whitespaces).isEmpty { return nil }
        let calendar = UIImage(systemName: "calendar")!
        return UILabel(text: text)
            .color(.appCellLabel)
            .font(UIFont.robotoRegular.withSize(14))
            .leftIcon(calendar, color: .appLightGray)
    }

    public var hours: UILabel? {
        let start = team.startHour
        let end = team.endHour
        let infix = start.isEmpty ? "" : " - "
        var text = start + infix + end
        if text.isEmpty { return nil }
        text += " (\(team.timeZone))"
        return UILabel(text: text)
            .color(.appCellLabel)
            .font(UIFont.robotoRegular.withSize(14))
            .leftIcon(UIImage(systemName: "clock")!, color: .appLightGray)
    }

    public var phone: UILabel? {
        guard let text = team.phone else { return nil }
        if text.isEmpty { return nil }
        return UILabel(text: text)
            .color(.appCellLabel)
            .font(UIFont.robotoRegular.withSize(14))
            .leftIcon(UIImage(systemName: "phone")!, color: .appLightGray)
    }

    public var duration: UILabel? {
        if team.duration.isEmpty { return nil }
        let label = UILabel(text: team.duration)
            .color(.appCellLabel)
            .font(UIFont.robotoRegular.withSize(14))
            .leftText("Duração", color: .appLightGray)
        return label
    }

    func region() -> TagGroupView? {
        let tags = team.operatingRegions.map({$0.initials})
        return TagGroupView(tags: tags, backGroundCell: .appBackgroundCell, tagBordered: true)
    }

    func currentDispatch() -> UIView? {
        guard let dispatch = dispatches.first else { return nil }
        return TeamDispatchView(dispatch: dispatch).configure()
    }

    var totalEquipament: Int {
        return team.equipments.count
    }

    var equipments: [Equipment] {
        return team.equipments
    }

    var people: [Person] {
        return team.teamPeople.map({$0.person})
    }

    var teamPeople: [TeamPerson] {
        return team.teamPeople
    }

    var id: UUID {
        team.id
    }

    var vehivles: [Equipment] {
        return team.getVehicles()
    }
}

public class NonCriticalCadResourceViewModel {
    private var team: NonCriticalTeam

    public init(team: NonCriticalTeam) {
        self.team = team
    }

    public func getTeam() -> NonCriticalTeam {
        return team
    }

    public var teamName: UILabel {
        return UILabel(text: team.name)
            .font(UIFont.robotoMedium.withSize(20))
    }

    public var dates: UILabel? {
        let startDate = team.startDateStr
        let endData = team.endDateStr
        let infix = startDate.isEmpty ? "" : " - "
        let text = " "+startDate + infix + endData
        if text.trimmingCharacters(in: .whitespaces).isEmpty { return nil }
        let calendar = UIImage(systemName: "calendar")!
        return UILabel(text: text)
            .color(.appCellLabel)
            .font(UIFont.robotoRegular.withSize(14))
            .leftIcon(calendar, color: .appLightGray)
    }

    public var hours: UILabel? {
        let start = team.startHour
        let end = team.endHour
        let infix = start.isEmpty ? "" : " - "
        var text = start + infix + end
        if text.isEmpty { return nil }
        text += " (\(team.timeZone))"
        return UILabel(text: text)
            .color(.appCellLabel)
            .font(UIFont.robotoRegular.withSize(14))
            .leftIcon(UIImage(systemName: "clock")!, color: .appLightGray)
    }

    public var duration: UILabel? {
        if team.duration.isEmpty { return nil }
        let label = UILabel(text: team.duration)
            .color(.appCellLabel)
            .font(UIFont.robotoRegular.withSize(14))
            .leftText("Duração", color: .appLightGray)
        return label
    }

    func regionAndAgencies() -> TagGroupView? {
        let tags = team.operatingRegions.map({ "\($0.initials) / \($0.agency.initials)" })
        return TagGroupView(tags: tags, backGroundCell: .clear, containerBackground: .clear, tagBordered: true)
    }

    var equipments: [Equipment] {
        return team.equipments
    }

    var teamPeople: [SimpleTeamPerson] {
        return team.teamPeople
    }

    var id: UUID {
        team.id
    }
}

extension UILabel {

    convenience init(text: String? ) {
        self.init()
        self.text = text
    }

    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    func leftIcon(_ image: UIImage, color: UIColor ) -> Self {
        let text = self.text ?? ""
        let attachement = NSTextAttachment(image: image.withTintColor(color))
        let attritbutedString = NSMutableAttributedString(attachment: attachement)
        let textWithIcon = NSAttributedString(string: " "+text)
        attritbutedString.append(textWithIcon)
        self.attributedText = attritbutedString
        return self
    }

    func leftText(_ leftText: String, color: UIColor, font: UIFont? = nil) -> Self {
        let text = self.text ?? ""
        let attritbutedString = NSMutableAttributedString(
            string: leftText,
            attributes: [
                NSAttributedString.Key.font: font ?? self.font!,
                NSAttributedString.Key.foregroundColor: color
        ])
        let textWithIcon = NSAttributedString(
            string: " "+text,
            attributes: [
                NSAttributedString.Key.font: self.font!,
                NSAttributedString.Key.foregroundColor: self.textColor!
            ])
        attritbutedString.append(textWithIcon)
        self.attributedText = attritbutedString
        return self
    }

    func color(_ color: UIColor) -> Self {
        textColor = color
        return self
    }

    func lines(_ value: Int) -> Self {
        numberOfLines = value
        return self
    }
}
