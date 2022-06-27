//
//  GenericDetailBuilder.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 03/06/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public struct GenericDetilBuilderConfigurations {
    public var regularLabelColor: UIColor = .appLightGray
    public var boldLabelColor: UIColor = .appCellLabel
    public var regularFontSize: CGFloat = 14
    public var boldFontSize: CGFloat = 14
    public var numberOfLinesBold: Int = 1
    public var numberOfLinesRegular: Int = 1
    public var hidesIfNull = false
    public var textIfNull = "Não informado"
    public var roundedLabelFontSize: CGFloat = 12
    public var roundedLabelBackGroundColor: UIColor = .appBlue
    public var verticalSpacing: CGFloat = 8
    public var horizontalSpacing: CGFloat = 8
    public var detailLabelBackgroundColor: UIColor = .clear
    public var regularLabelBackgroundColor: UIColor = .clear
}

public class GenericDetailBuilder: NSObject {

    public override init() {
        super.init()
    }

    private var interactions = [ActionBuilder]()

    public var configurations = GenericDetilBuilderConfigurations()

    public func horizontalDivider(lineWidth: CGFloat, color: UIColor) -> UIView {
        let view = UIView()
        view.enableAutoLayout()
        view.height(lineWidth)
        view.backgroundColor = color
        return view
    }

    public func verticalStack(spacing: CGFloat? = nil, alignment: UIStackView.Alignment = .fill,
                              distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = distribution
        stack.spacing = spacing ?? configurations.verticalSpacing
        stack.alignment = alignment
        return stack
    }

    public func horizontalStack(spacing: CGFloat? = nil, alignment: UIStackView.Alignment = .fill) -> UIStackView {
        let stack = verticalStack()
        stack.axis = .horizontal
        stack.alignment = alignment
        stack.spacing = spacing ?? configurations.horizontalSpacing
        return stack
    }

    public func labelBold(with text: String?, color: UIColor? = nil, size: CGFloat?  = nil, numberOfLines: Int = 1) -> UILabel {
        let label = UILabel()
        label.font = UIFont.robotoBold.withSize( size ?? configurations.boldFontSize )
        label.textColor = color ?? configurations.boldLabelColor
        label.numberOfLines = numberOfLines
        label.isHidden = text == nil && configurations.hidesIfNull
        label.text = text ?? configurations.textIfNull
        return label
    }

    public func labelRegular(with text: String?, size: CGFloat? = nil, color: UIColor? = nil,
                             hasInteraction: Bool = false, hasMapInteraction: Bool = false ) -> UILabel {
        let label = UILabel()
        label.font = UIFont.robotoRegular.withSize( size ?? configurations.regularFontSize )
        label.textColor = color ?? configurations.regularLabelColor
        label.numberOfLines = configurations.numberOfLinesRegular
        label.isHidden = text == nil && configurations.hidesIfNull
        label.text = text ?? configurations.textIfNull
        label.backgroundColor = configurations.regularLabelBackgroundColor
        if hasInteraction {
            let text = label.text ?? ""
            label.text = nil
            let actionBuilder = ActionBuilder(text: text, hasMapInteraction: hasMapInteraction )
            interactions.append(actionBuilder)
            let interaction = UIContextMenuInteraction(delegate: actionBuilder)
            label.addInteraction(interaction)
            label.isUserInteractionEnabled = true
            let textRange = NSRange(location: 0, length: text.count )
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSAttributedString.Key.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue, range: textRange)
            label.attributedText = attributedText
            interaction.view?.backgroundColor = label.backgroundColor
            interaction.view?.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        }

        return label
    }

    public func titleDetail(title: String, detail: String, linesDetail: Int = 0,
                            hasInteraction: Bool = false,
                            hasMapInteraction: Bool = false,
                            exceptedModulesInInteraction: [String] = [],
                            hasWarning: Bool = false,
                            onTap: UITapGestureRecognizer? = nil) -> UIStackView {
        let titleLabel = labelBold(with: title)
        let detailLabel = labelRegular(with: detail)
        detailLabel.backgroundColor = configurations.detailLabelBackgroundColor
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        detailLabel.numberOfLines = linesDetail
        let stack = verticalStack(spacing: 6)
        stack.distribution = .fillProportionally
        stack.alignment = .top

        if hasWarning {
            let titleStack = horizontalStack(spacing: 4.0, alignment: .leading)
            let warningMessageIcon: UIImageView = {
                let image = UIImage(systemName: "exclamationmark.circle.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
                let view = UIImageView(image: image)
                return view
            }()
            titleStack.addArrangedSubview(titleLabel)
            titleStack.addArrangedSubview(warningMessageIcon)
            NSLayoutConstraint.activate([
                warningMessageIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
            ])

            stack.addArrangedSubview(titleStack)
        } else {
            stack.addArrangedSubview(titleLabel)
        }

        stack.addArrangedSubview(detailLabel)

        if let onTap = onTap {
            stack.isUserInteractionEnabled = true
            stack.addGestureRecognizer(onTap)
        }

        if hasInteraction {
            let text = detailLabel.text ?? ""
            detailLabel.text = nil
            let actionBuilder = ActionBuilder(text: text, hasMapInteraction: hasMapInteraction, exceptedModuleNames: exceptedModulesInInteraction)
            let interaction = UIContextMenuInteraction(delegate: actionBuilder)
            interactions.append(actionBuilder)
            detailLabel.addInteraction(interaction)
            detailLabel.isUserInteractionEnabled = true

            let textRange = NSRange(location: 0, length: text.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSAttributedString.Key.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue, range: textRange)
            detailLabel.attributedText = attributedText
            interaction.view?.backgroundColor = detailLabel.backgroundColor
            interaction.view?.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        }
        return stack
    }

    public func line( views: UIView? ..., distribuition: UIStackView.Distribution = .fill, spacing: CGFloat? = nil,
                      alignment: UIStackView.Alignment = .top ) -> UIStackView {
        return self.line(views: views, distribuition: distribuition, spacing: spacing, alignment: alignment)
    }

    public func line(views: [UIView?], distribuition: UIStackView.Distribution = .fill,
                     spacing: CGFloat? = nil, alignment: UIStackView.Alignment = .top ) -> UIStackView {
        let lineStack = UIStackView()
        lineStack.axis = .horizontal
        lineStack.distribution = distribuition
        lineStack.alignment = alignment
        lineStack.spacing = spacing ?? configurations.horizontalSpacing
        views.filter({$0 != nil }).forEach({lineStack.addArrangedSubview($0!)})
        return lineStack
    }

    public func buildRoundedLabel(_ nature: String, color: UIColor? = nil ) -> UILabel {
        if nature.isEmpty {
            return UILabel()
        }
        let natureLabel = PaddingLabel(withInsets: 5, 5, 8, 8)
        natureLabel.text = nature
        natureLabel.numberOfLines = 0
        natureLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        natureLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        natureLabel.backgroundColor = color ?? configurations.roundedLabelBackGroundColor
        natureLabel.layer.cornerRadius = 5
        natureLabel.layer.masksToBounds = true
        natureLabel.font = UIFont.robotoRegular.withSize(configurations.roundedLabelFontSize)
        natureLabel.textColor = .white
        return natureLabel
    }

    public func headerSection(with text: String, backgroundGolor: UIColor = .appSectionHeader ) -> UIView {
        let label = labelRegular(with: text, color: .appCellLabel)
        label.backgroundColor = .clear
        let header = UIView()
        label.font = UIFont.robotoMedium.withSize(16)
        header.backgroundColor = backgroundGolor
        header.enableAutoLayout().height(33)
        header.addSubview(label)
        label.enableAutoLayout().fillSuperView(regardSafeArea: true)
        return header
    }

    public func tagsDetail(title: String, tags: [String]) -> UIView {
        let titleLabel = labelBold(with: title)
        let tagsView = buildTags(tags)
        let stack = verticalStack()
        tagsView.setContentCompressionResistancePriority(.required, for: .horizontal)
        tagsView.setContentCompressionResistancePriority(.required, for: .vertical)
        stack.distribution = .fillProportionally
        stack.alignment = .top
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(tagsView)
        tagsView.width(stack)
        return stack
    }

    public func customDetail(title: String, view: UIView) -> UIView {
        let titleLabel = labelBold(with: title)
        let stack = verticalStack()
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        stack.distribution = .fillProportionally
        stack.alignment = .top
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(view)
        view.width(stack)
        return stack
    }

    public func buildTags(_ tags: [String]) -> UIView {
        return TagGroupView(tags: tags, containerBackground: .clear).enableAutoLayout().height(40)
    }

    public func sectionTitle(with text: String, andExtra extra: UIView? = nil, hasInteraction: Bool = false) -> UIView {
        let label = labelRegular(with: text, color: .appCellLabel, hasInteraction: hasInteraction).enableAutoLayout()
        label.backgroundColor = .clear
        let header = UIView()
        label.font = UIFont.robotoMedium.withSize(17)
        header.enableAutoLayout()
        header.addSubview(label)
        if let extraView = extra {
            header.addSubview(extraView)
            extraView.enableAutoLayout()
            label.height(header)
            extraView.height(header)
            NSLayoutConstraint.activate([
                extraView.trailingAnchor.constraint(equalTo: header.trailingAnchor),
                label.leadingAnchor.constraint(equalTo: header.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: extraView.leadingAnchor, constant: -15)
            ])
        } else {
            label.fillSuperView()
        }
        header.bringSubviewToFront(label)
        return header
    }
}
