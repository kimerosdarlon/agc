//
//  MemberCollectionViewCell.swift
//  CAD
//
//  Created by Ramires Moreira on 08/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class MemberCollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: MemberCollectionViewCell.self)

    private var memberImageView: UIImageView = {
        let size: CGFloat = 52
        let imageView = UIImageView().height(size).width(size)
        imageView.backgroundColor = .imageBackGround
        imageView.layer.cornerRadius = size/2
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView.enableAutoLayout()
    }()

    private var memberProfileView = UIView().enableAutoLayout()

    private var labelName: UILabel = {
        return UILabel()
            .font(UIFont.robotoBold.withSize(14))
            .color(.appCellLabel).lines(0)
    }()

    private var labelTeamRole: UILabel = {
        return UILabel()
            .font(UIFont.italicSystemFont(ofSize: 14))
            .color(.appCellLabel).lines(0)
    }()

    private var labelRole: UILabel = {
        return UILabel()
            .font(UIFont.robotoRegular.withSize(14))
            .color(.appCellLabel).lines(0)
    }()

    private var onlineMarker: UIView = {
        let view = UIView().enableAutoLayout()
        view.backgroundColor = UIColor.appGreenMarker.lighter(by: 0.2)
        view.layer.cornerRadius = 9
        return view
    }()

    func configure(withName name: String, role: String, image: UIImage, isOnline: Bool = false) {
        memberImageView.image = image
        labelRole.text = role
        labelName.text = name
        onlineMarker.isHidden = !isOnline
        contentView.backgroundColor = .memberBackGroundCell
    }

    func configure(withName name: String, teamRole: String, role: String, image: UIImage, isOnline: Bool = false) {
        memberImageView.image = image
        labelRole.text = role
        labelTeamRole.text = teamRole
        labelName.text = name
        onlineMarker.isHidden = !isOnline
        contentView.backgroundColor = .memberBackGroundCell
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
        memberImageView.overrideUserInterfaceStyle = UserStylePreferences.theme.style

        let size: CGFloat = 52
        memberProfileView.height(size).width(size)
        memberProfileView.addSubview(memberImageView)
        memberProfileView.addSubview(onlineMarker)
        memberImageView.left(memberProfileView, mutiplier: 0).top(memberProfileView, mutiplier: 0)
        onlineMarker.right(to: memberImageView.trailingAnchor, -10)
            .bottom(to: memberImageView.bottomAnchor, -10)
            .width(18).height(18)
        onlineMarker.layer.borderWidth = 3
        onlineMarker.layer.borderColor = UIColor.memberBackGroundCell.cgColor

        let contentStack = UIStackView().enableAutoLayout()
        contentStack.alignment = .center
        contentStack.spacing = 16

        let labelsStack = UIStackView()
        labelsStack.axis = .vertical
        labelsStack.spacing = 3
        labelsStack.alignment = .leading

        labelsStack.addArrangedSubview(labelName)
        labelsStack.addArrangedSubview(labelRole)
        if labelTeamRole.text != nil {
            labelsStack.addArrangedSubview(labelTeamRole)
        }
        contentStack.addArrangedSubview(memberProfileView)
        contentStack.addArrangedSubview(labelsStack)

        contentView.addSubview(contentStack)
        contentStack.fillSuperView(regardSafeArea: true)
        contentView.layer.cornerRadius = 8
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        contentView.backgroundColor = .memberBackGroundCell
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        memberImageView.image = nil
    }
}
