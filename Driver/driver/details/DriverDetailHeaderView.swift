//
//  DriverDetailHeaderView.swift
//  Driver
//
//  Created by Samir Chaves on 15/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

enum DriverDetailHeaderHeight: CGFloat {
    case expanded = 140.0
    case shrinked = 60.0
}

protocol DriverDetailHeaderDelegate: class {
    func didTapOnAlertMessage()
}

class DriverDetailHeaderView: UIView {
    var details: Driver!
    weak var delegate: DriverDetailHeaderDelegate?
    private var animatedTextHeight = [NSLayoutConstraint]()
    private let expandedHeaderHeight = DriverDetailHeaderHeight.expanded.rawValue
    private let shrinkedHeaderHeight = DriverDetailHeaderHeight.shrinked.rawValue
    private var statusBadge = DriverStatusBadge()
    private var warningMessageLabel = UILabel.build(withSize: 13, color: .appYellow)
    private var warningMessageIcon: UIImageView = {
        let image = UIImage(systemName: "exclamationmark.circle.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let view = UIImageView(image: image)
        view.enableAutoLayout()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let warningMessage: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .leading
        view.distribution = .fillProportionally
        view.spacing = 5.0
        return view
    }()

    fileprivate var actionBuilder: ActionBuilder!

    private let headerInfo: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 4.0
        view.axis = .vertical
        view.contentMode = .scaleToFill
        return view
    }()

    private let titleText: UILabel = {
        let text = UILabel()
        text.numberOfLines = 0
        text.textColor = .appTitle
        text.enableAutoLayout()
        text.layer.masksToBounds = true
        return text
    }()

    private let genrerText: UILabel = {
        let text = UILabel()
        text.enableAutoLayout()
        text.textColor = .appTitle
        text.layer.masksToBounds = true
        return text
    }()

    private let yearsText: UILabel = {
        let text = UILabel()
        text.enableAutoLayout()
        text.contentMode = .scaleToFill
        text.numberOfLines = 0
        text.textColor = .appTitle
        text.layer.masksToBounds = true
        return text
    }()

    private let driverImage: UIImageView = {
        let view = UIImageView()
        view.enableAutoLayout()
        view.image = UIImage(named: "roundedUser")
        view.backgroundColor = .white
        view.adjustsImageSizeForAccessibilityContentSizeCategory = true
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 3
        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = 15.0
        view.backgroundColor = .appBackground
        return view
    }()

    init() {
        super.init(frame: .zero)
    }

    private func getAge(from birthDate: Date?) -> String {
        if let date = birthDate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year], from: date, to: Date())
            return "\(components.year!) anos"
        }

        return ""
    }

    func configure(withDriver details: Driver) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let birthDate = formatter.date(from: details.individual.birth.date)

        yearsText.attributedText = NSAttributedString(string: getAge(from: birthDate), attributes: [.font: UIFont.systemFont(ofSize: 18.0)])
        yearsText.overrideUserInterfaceStyle = UserStylePreferences.theme.style

        genrerText.attributedText = NSAttributedString(string: details.individual.sex, attributes: [.font: UIFont.systemFont(ofSize: 12.0)])
        genrerText.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        genrerText.alpha = 0.7

        statusBadge.setStatus(details.general.currentCnh.status)

        titleText.attributedText = NSAttributedString(string: details.individual.name, attributes: [.font: UIFont.systemFont(ofSize: 16.0, weight: .bold), .underlineStyle: NSUnderlineStyle.single.rawValue])
        titleText.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        actionBuilder = ActionBuilder(text: details.individual.name)
        let interaction = UIContextMenuInteraction(delegate: self)
        titleText.addInteraction(interaction)
        titleText.isUserInteractionEnabled = true
        interaction.view?.backgroundColor = .appBackground
        addSubviews()
        setupConstraints()

        if let cnhWarning = details.general.currentCnh.cnhWarning {
            NSLayoutConstraint.activate([
                warningMessage.leadingAnchor.constraint(equalTo: driverImage.trailingAnchor, constant: 10),
                warningMessage.topAnchor.constraint(equalTo: headerInfo.bottomAnchor, constant: 5),
                warningMessage.trailingAnchor.constraint(equalTo: headerInfo.trailingAnchor, constant: -20),
                warningMessageLabel.centerYAnchor.constraint(equalTo: warningMessageIcon.centerYAnchor)
            ])

            stackView.spacing = 10.0
            stackView.alignment = .top
            warningMessageLabel.attributedText = NSAttributedString(string: cnhWarning.message, attributes: [.font: UIFont.italicSystemFont(ofSize: 13)])

            let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.alertMessageTapped(_:)))
            let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.alertMessageTapped(_:)))
            let viewTap = UITapGestureRecognizer(target: self, action: #selector(self.alertMessageTapped(_:)))
            warningMessageLabel.isUserInteractionEnabled = true
            warningMessageLabel.addGestureRecognizer(labelTap)
            warningMessageIcon.isUserInteractionEnabled = true
            warningMessageIcon.addGestureRecognizer(iconTap)
            warningMessage.isUserInteractionEnabled = true
            warningMessage.addGestureRecognizer(viewTap)
        }

        self.backgroundColor = UIColor.appBackground

    }

    @objc func alertMessageTapped(_ sender: UITapGestureRecognizer) {
        delegate?.didTapOnAlertMessage()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.addSubview(stackView)
        stackView.addSubview(warningMessage)

        warningMessage.addArrangedSubviewList(views: [
            warningMessageIcon,
            warningMessageLabel
        ])

        headerInfo.addArrangedSubviewList(views: [
            titleText,
            yearsText,
            genrerText,
            statusBadge
        ])

        stackView.addArrangedSubviewList(views: [
            driverImage,
            headerInfo
        ])
    }

    func setTheme() {
        self.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        self.subviews.forEach { view in
            view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        }
    }

    func layoutIfNeeded(withHeight height: CGFloat) {
        setupConstraints()
        let sizeFactor = (height - shrinkedHeaderHeight) / (expandedHeaderHeight - shrinkedHeaderHeight)
        let easingFactor = pow(sizeFactor, 4)
        genrerText.attributedText = NSAttributedString(string: genrerText.attributedText?.string ?? "", attributes: [.font: UIFont.systemFont(ofSize: 12.0 * sizeFactor)])
        yearsText.attributedText = NSAttributedString(string: yearsText.attributedText?.string ?? "", attributes: [.font: UIFont.systemFont(ofSize: 18.0 * sizeFactor)])
        warningMessageLabel.attributedText = NSAttributedString(string: warningMessageLabel.attributedText?.string ?? "", attributes: [.font: UIFont.italicSystemFont(ofSize: 13.0 * sizeFactor)])
        genrerText.alpha = 0.7 * easingFactor
        yearsText.alpha = easingFactor
        warningMessageLabel.alpha = easingFactor
        warningMessageIcon.alpha = easingFactor
        warningMessageIcon.transform = .init(scaleX: easingFactor, y: easingFactor)

        super.layoutIfNeeded()
    }

    private func setupConstraints() {
        warningMessage.enableAutoLayout()

        NSLayoutConstraint.activate([
            driverImage.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1),
            driverImage.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1),

            titleText.trailingAnchor.constraint(equalTo: headerInfo.trailingAnchor, constant: 30),

            stackView.heightAnchor.constraint(equalTo: heightAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 15)
        ])
    }
}

extension DriverDetailHeaderView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
      _ interaction: UIContextMenuInteraction,
      configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return actionBuilder.contextMenuInteraction(interaction, configurationForMenuAtLocation: location)
    }
}
