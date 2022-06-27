//
//  WarrantHeader.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 12/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class WarrantDetailHeader: UIViewController {

    private let details: WarrantDetails
    private let stack = UIStackView()

    private let statusLabel: PaddingLabel = {
        let label = PaddingLabel(withInsets: 3, 3, 5, 5)
        label.font = UIFont.robotoRegular.withSize(13)
        label.backgroundColor = .appRed
        label.textColor = .white
        label.enableAutoLayout()
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoBold.withSize(17)
        label.textColor = .appCellLabel
        label.numberOfLines = 0
        return label
    }()

    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoRegular.withSize(17)
        label.textColor = .appCellLabel
        return label
    }()

    private let ageLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.font = UIFont.robotoRegular.withSize(17)
        label.textColor = .appCellLabel
        return label
    }()

    private let locationLabel: UITextField = {
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
        textField.textColor = UIColor.appTitle.withAlphaComponent(0.7)
        return textField
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.enableAutoLayout()
        imageView.image = UIImage(named: "user")
        imageView.layer.cornerRadius = 3
        return imageView
    }()

    private var personalStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.enableAutoLayout()
        return stack
    }()

    var actionBuilder: ActionBuilder?

    init(details: WarrantDetails) {
        self.details = details
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if details.personal.hasBirthDate {
            ageLabel.text = details.personal.age
        }
        let warrantNumnerView = GenericCollectionViewCell()
        warrantNumnerView.configure(using: ItemDetail(title: "Número do Mandado", detail: details.piece.processNumber, colunms: 2))

        let dateView = GenericCollectionViewCell()
        dateView.configure(using: ItemDetail(title: "Expedido em", detail: details.expedition.dateFormatted, colunms: 1))

        let motivoView = GenericCollectionViewCell()
        motivoView.configure(using: ItemDetail(title: "Motivo da Expedição", detail: details.expedition.reason, colunms: 3.0, detailBackGroundColor: .appBlue))

        let stackHorizontal = UIStackView()
        stackHorizontal.axis = .horizontal
        stackHorizontal.distribution = .fillEqually
        stackHorizontal.addArrangedSubview(warrantNumnerView)
        stackHorizontal.addArrangedSubview(dateView)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.addArrangedSubview(stackHorizontal)
        stack.addArrangedSubview(motivoView)

        statusLabel.text = details.piece.situation
        locationLabel.text = "\(details.expedition.organ.city), \(details.expedition.organ.state)"
        if locationLabel.text!.isEmpty {
            locationLabel.leftViewMode = .never
        }
        setName(details.personal.name.first ?? "")
        nickNameLabel.text = details.personal.nickname.first
        addSubviews()
        setupContraints()
    }

    func setName(_ text: String ) {
        actionBuilder = ActionBuilder(text: text)

        let interaction = UIContextMenuInteraction(delegate: actionBuilder!)
        nameLabel.addInteraction(interaction)
        nameLabel.isUserInteractionEnabled = true

        let textRange = NSRange(location: 0, length: text.count )
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue, range: textRange)
        nameLabel.attributedText = attributedText
        interaction.view?.backgroundColor = nameLabel.backgroundColor
    }

    func addSubviews() {
        personalStackView.addArrangedSubview(nameLabel)
        personalStackView.addArrangedSubview(nickNameLabel)
        if let city = locationLabel.text {
            personalStackView.addArrangedSubviewIf(!city.isEmpty, locationLabel)
        }
        personalStackView.addArrangedSubview(ageLabel)
        view.addSubview(stack)
        view.addSubview(personalStackView)
        view.addSubview(imageView)
        view.addSubview(statusLabel)
    }

    func setupContraints() {
        stack.enableAutoLayout()
        let collectionView = stack
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1),
            imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 2),
            personalStackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            personalStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1),
            personalStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            statusLabel.topAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1),
            statusLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: statusLabel.bottomAnchor, multiplier: 1),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: collectionView.trailingAnchor, multiplier: 1),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
