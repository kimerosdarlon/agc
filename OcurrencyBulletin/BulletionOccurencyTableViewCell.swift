//
//  BulletionOccurencyTableViewCell.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 22/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class BulletionOccurencyTableViewCell: UITableViewCell {

    weak var delegate: OccurrencyBulletinExpandDelegate?
    static let identifier = String(describing: BulletionOccurencyTableViewCell.self)
    private var id = 0
    let indicator = UIActivityIndicatorView(style: .large)

    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()

    private let verticalExpandedStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()

    private let cityLabel: UITextField = {
        let textField = UITextField()
        let image = UIImageView(image: UIImage(named: "mapPin"), highlightedImage: nil)
        image.enableAutoLayout()
        image.width(12).height(10)
        image.contentMode = .scaleAspectFit
        textField.leftView = image
        textField.leftViewMode = .always
        textField.textAlignment = .left
        textField.isUserInteractionEnabled = false
        textField.enableAutoLayout()
        textField.font = UIFont.robotoRegular.withSize(14)
        textField.textColor = .appLightGray
        return textField
    }()

    private let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 16
        return stack
    }()

    func configure(with model: BulletinItem, tag: Int, expanded: Bool = false) {
        id = tag
        verticalStack.addArrangedSubview(labelRegular(with: model.codeNational))
        addDateAndLocale(model)
        verticalStack.addArrangedSubview(labelBold(with: "Unidade de registro"))
        let registryPoliceStationLabel = labelRegular(with: model.registryPoliceStation)
        registryPoliceStationLabel.numberOfLines = 0
        verticalStack.addArrangedSubview(registryPoliceStationLabel)

        let responsiblePoliceStation = model.responsiblePoliceStation
        let registryPoliceStation = model.registryPoliceStation
        if !responsiblePoliceStation.elementsEqual(registryPoliceStation) {
            verticalStack.addArrangedSubview(labelBold(with: "Unidade de apuração"))
            let registryPoliceStationLabel = labelRegular(with: model.responsiblePoliceStation)
            registryPoliceStationLabel.numberOfLines = 0
            verticalStack.addArrangedSubview(registryPoliceStationLabel)
        }
        contentView.backgroundColor = .appBackgroundCell
        backgroundColor = .appBackground
        if expanded {
            congigureExpanded(with: model)
        } else {
            verticalExpandedStack.removeFromSuperview()
        }
        addIcons(with: model, expanded: expanded)
        contentView.addSubview(verticalStack)
        verticalStack.enableAutoLayout()
        verticalStack.fillSuperView(regardSafeArea: true)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleExpanded))
        horizontalStack.addGestureRecognizer(tap)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }

    fileprivate func buildNatureLabel(_ nature: String) -> UILabel {
        let natureLabel = PaddingLabel(withInsets: 5, 5, 8, 8)
        natureLabel.text = nature
        natureLabel.numberOfLines = 1
        natureLabel.backgroundColor = .appBlue
        natureLabel.layer.cornerRadius = 5
        natureLabel.layer.masksToBounds = true
        natureLabel.font = UIFont.robotoRegular.withSize(12)
        natureLabel.textColor = .white
        return natureLabel
    }

    func congigureExpanded(with model: BulletinItem) {
        verticalExpandedStack.arrangedSubviews.forEach({$0.removeFromSuperview()})
        let peopleLabel = buildIcon(for: .people, label: labelBold(with: "Pessoas envolvidas"), iconOnLeft: true)
        peopleLabel.addArrangedSubview(UIView())
        verticalExpandedStack.addArrangedSubview(peopleLabel)
        for personInvolved in model.peopleInvolved {
            verticalExpandedStack.setCustomSpacing(16, after: verticalExpandedStack.arrangedSubviews.last!)
            let name =  personInvolved.name ?? personInvolved.nickname ?? "Não informado"
            let nameLB = labelRegular(with: name + personInvolved.ageStr)
            verticalExpandedStack.addArrangedSubview(nameLB)
            for involvement in personInvolved.involvements {
                let involvementType = buildNatureLabel(involvement.nature)
                let statck = UIStackView()
                statck.axis = .horizontal
                statck.addArrangedSubview(involvementType)
                statck.addArrangedSubview(.spacer())
                verticalExpandedStack.addArrangedSubview(statck)
            }
        }
        verticalStack.addArrangedSubview(verticalExpandedStack)
        verticalStack.setCustomSpacing(16, after: verticalExpandedStack)
    }

    override func prepareForReuse() {
        id = 0
        verticalStack.arrangedSubviews.forEach({$0.removeFromSuperview()})
        horizontalStack.arrangedSubviews.forEach({$0.removeFromSuperview()})
        indicator.removeFromSuperview()
        indicator.stopAnimating()
    }

    func labelBold(with text: String?) -> UILabel {
        let label = UILabel()
        label.font = UIFont.robotoBold.withSize(14)
        label.textColor = .appCellLabel
        label.numberOfLines = 1
        label.text = text ?? "Não informado"
        return label
    }

    func labelRegular(with text: String?, size: CGFloat = 14, color: UIColor? = nil ) -> UILabel {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize(size)
        label.textColor = color ?? .appLightGray
        label.numberOfLines = 1
        label.text = text ?? "Não informado"
        return label
    }

    func addIcons(with model: BulletinItem, expanded: Bool) {
        let peopleCount = model.peopleInvolved.count
        let vehiclheCount = model.objects.vehicles.count
        let weaponCount = model.objects.weapons.count
        let cellphoneCount = model.objects.cellphones.count
        let otherCount = model.objects.others.count
        if !expanded {
            horizontalStack.addArrangedSubview(buildIcon(for: .people, andQuantity: peopleCount))
        }
        horizontalStack.addArrangedSubview(buildIcon(for: .vehicle, andQuantity: vehiclheCount))
        horizontalStack.addArrangedSubview(buildIcon(for: .weapon, andQuantity: weaponCount))
        horizontalStack.addArrangedSubview(buildIcon(for: .cellphone, andQuantity: cellphoneCount))
        horizontalStack.addArrangedSubview(buildIcon(for: .other, andQuantity: otherCount))
        horizontalStack.addArrangedSubview(UIView())
        let chevronDown = UIImageView(image: UIImage(systemName: expanded ? "chevron.up" : "chevron.down" ))
        chevronDown.contentMode = .scaleAspectFit
        horizontalStack.addArrangedSubview( chevronDown )
        verticalStack.addArrangedSubview(horizontalStack)
    }

    func buildIcon(for type: BulletinObjectType, andQuantity quantity: Int ) -> UIStackView {
        let quantityLabel = labelBold(with: "\(quantity)")
        return buildIcon(for: type, label: quantityLabel)
    }

    func buildIcon(for type: BulletinObjectType, label: UILabel, iconOnLeft: Bool = false ) -> UIStackView {
        let quantityLabel = label
        quantityLabel.numberOfLines = 1
        let image = UIImageView(image: type.image.withTintColor(.appCellLabel, renderingMode: .alwaysOriginal) )
        image.contentMode = .scaleAspectFit
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
        stack.distribution = .fill
        let leftView = iconOnLeft ? image : quantityLabel
        let rightView = iconOnLeft ? quantityLabel : image
        stack.addArrangedSubview(leftView)
        stack.addArrangedSubview(rightView)
        return stack
    }

    fileprivate func addDateAndLocale(_ model: BulletinItem) {
        let stack = UIStackView()
        stack.enableAutoLayout()
        stack.axis = .horizontal
        stack.distribution = .fill

        let label = labelRegular(with: model.formatedRegistryDateTime)
        label.textAlignment = .left
        stack.addArrangedSubview(label)

        if let city = model.city, let state = model.state {
            cityLabel.text = "\(city), \(state)"
            cityLabel.textAlignment = .right
            stack.addArrangedSubview(UIView())
            stack.addArrangedSubview(cityLabel)
        }

        if !stack.arrangedSubviews.isEmpty {
            verticalStack.addArrangedSubview(stack)
        }
    }

    @objc
    func toggleExpanded() {
        delegate?.toggleExpandBulletin(with: id)
    }

    func setLoading( _ value: Bool ) {
        if value {
            indicator.color = .appBlue
            verticalStack.addSubview(indicator)
            indicator.startAnimating()
            indicator.enableAutoLayout()
            indicator.fillSuperView(regardSafeArea: true)
        } else {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}

protocol OccurrencyBulletinExpandDelegate: class {

    func toggleExpandBulletin(with id: Int)
}
