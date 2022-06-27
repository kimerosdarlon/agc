//
//  ListBasedDetailBuilder.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 22/10/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public typealias DetailItem = (title: String, detail: String)
public typealias DetailTagsItem = (title: String, tags: [String])
public typealias CustomDetailItem = (title: String, view: UIView)
public class InteractableDetailItem {
    public var detail: String?
    public var title: String
    public var tags: [String]?
    public var view: UIView?
    public var exceptedModulesInInteraction: [String]
    public var hasInteraction: Bool
    public var hasMapInteraction: Bool
    public var hasWarning: Bool
    public var onTap: UITapGestureRecognizer?

    static public func noInteraction(_ item: DetailItem) -> InteractableDetailItem {
        return InteractableDetailItem(fromItem: item, hasInteraction: false)
    }

    static public func noInteraction(_ items: [DetailItem]) -> [InteractableDetailItem] {
        return items.map { InteractableDetailItem.noInteraction($0) }
    }

    static public func noInteraction(_ itemsList: [[DetailItem]]) -> [[InteractableDetailItem]] {
        return itemsList.map { items in
            items.map { InteractableDetailItem.noInteraction($0) }
        }
    }

    public init(fromItem item: DetailItem,
                hasInteraction: Bool = true,
                hasMapInteraction: Bool = false,
                exceptedModulesInInteraction: [String] = [],
                hasWarning: Bool = false,
                onTap: UITapGestureRecognizer? = nil) {
        title = item.title
        detail = item.detail
        self.exceptedModulesInInteraction = exceptedModulesInInteraction
        self.hasInteraction = hasInteraction
        self.hasMapInteraction = hasMapInteraction
        self.hasWarning = hasWarning
        self.onTap = onTap
    }

    public init(fromItem item: CustomDetailItem) {
        title = item.title
        view = item.view
        self.exceptedModulesInInteraction = []
        self.hasInteraction = false
        self.hasMapInteraction = false
        self.hasWarning = false
    }

    public init(fromItem item: DetailTagsItem) {
        title = item.title
        tags = item.tags
        self.exceptedModulesInInteraction = []
        self.hasInteraction = false
        self.hasMapInteraction = false
        self.hasWarning = false
    }
}

public class DetailsGroup {
    internal var items: [[InteractableDetailItem]]
    internal var title: String?
    internal var titleHasInteraction: Bool = false
    internal var tags = [String]()
    internal var header: String?
    internal var customHeader: UIView?
    internal var extraView: UIView?

    public init(items: [[DetailItem]], withHeader header: String? = nil, withTitle title: String? = nil, withTags tags: [String] = [], withExtra extra: UIView? = nil, withCustomHeader customHeader: UIView? = nil, titleHasInteraction: Bool = false) {
        self.header = header
        self.customHeader = customHeader
        self.title = title
        self.tags = tags
        self.items = items.map { line in
            line.map { item in
                return InteractableDetailItem(fromItem: item, hasInteraction: false, hasMapInteraction: false)
            }
        }
        self.extraView = extra
        self.titleHasInteraction = titleHasInteraction
    }

    public init(items: [[InteractableDetailItem]], withHeader header: String? = nil, withTitle title: String? = nil, withTags tags: [String] = [], withExtra extra: UIView? = nil, withCustomHeader customHeader: UIView? = nil, titleHasInteraction: Bool = false) {
        self.items = items
        self.header = header
        self.extraView = extra
        self.customHeader = customHeader
        self.tags = tags
        self.title = title
        self.titleHasInteraction = titleHasInteraction
    }

    public func addTagItem(_ tagItem: DetailTagsItem) {
        self.items.append([InteractableDetailItem(fromItem: tagItem)])
    }
}

public class DetailsBlock: Hashable {
    public let identitier: String
    internal var groups: [DetailsGroup]

    public init(groups: [DetailsGroup], identifier: String) {
        self.groups = groups
        self.identitier = identifier
    }

    public init(group: DetailsGroup, identifier: String) {
        self.groups = [group]
        self.identitier = identifier
    }

    public init(item: DetailItem, identifier: String) {
        self.groups = [DetailsGroup(items: [[item]])]
        self.identitier = identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identitier)
    }

    public static func == (lhs: DetailsBlock, rhs: DetailsBlock) -> Bool {
        lhs.identitier == rhs.identitier
    }
}

public class ListBasedDetailBuilder {
    public var builder: GenericDetailBuilder!
    public var containerView: UIView!
    private var containerBottomConstraint: NSLayoutConstraint?
    private var padding: UIEdgeInsets!
    private var spacing: CGFloat = 15
    private var widthMultiplier: CGFloat = 0.925
    public var blocksViews = [UIView]()

    public init(into containerView: UIView,
                boldFontSize: CGFloat = 13,
                regularFontSize: CGFloat = 16,
                padding: UIEdgeInsets = .init(top: 15, left: 15, bottom: 15, right: 15),
                spacing: CGFloat = 15,
                widthMultiplier: CGFloat = 0.925) {
        let builder = GenericDetailBuilder()
        builder.configurations.regularLabelColor = UIColor.appTitle.withAlphaComponent(0.6)
        builder.configurations.boldLabelColor = .appTitle
        builder.configurations.boldFontSize = boldFontSize
        builder.configurations.regularFontSize = regularFontSize
        builder.configurations.verticalSpacing = 2
        self.builder = builder
        self.containerView = containerView
        self.padding = padding
        self.spacing = spacing
        self.widthMultiplier = widthMultiplier
    }

    private func getVerticalStack() -> UIStackView {
        let stack = builder.verticalStack(spacing: 15, alignment: .fill, distribution: .fill)
        stack.layoutMargins = padding
        stack.isLayoutMarginsRelativeArrangement = true
        stack.enableAutoLayout()
        stack.backgroundColor = .appBackground
        return stack
    }

    public func setupLayout() {
        containerBottomConstraint?.isActive = false
        for (i, block) in blocksViews.enumerated() {
            if i == 0 {
                block.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: spacing).isActive = true
            } else {
                block.topAnchor.constraint(equalTo: blocksViews[i - 1].bottomAnchor, constant: spacing).isActive = true
            }

            NSLayoutConstraint.activate([
                block.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: widthMultiplier),
                block.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor)
            ])

            if i == blocksViews.count - 1 {
                containerBottomConstraint = self.containerView.bottomAnchor.constraint(equalTo: block.bottomAnchor, constant: spacing)
                containerBottomConstraint?.isActive = true
            }
        }
    }

    public func buildDetailsBlock(_ block: DetailsBlock) {
        buildDetailsBlocks([block])
    }

    private func buildDetailItem(from item: InteractableDetailItem) -> UIView {
        if item.view != nil {
            return builder.customDetail(
                title: item.title,
                view: item.view!
            )
        } else if item.tags != nil {
            return builder.tagsDetail(
                title: item.title,
                tags: item.tags!
            )
        } else {
            return builder.titleDetail(
                title: item.title,
                detail: item.detail ?? "",
                hasInteraction: item.hasInteraction,
                hasMapInteraction: item.hasMapInteraction,
                exceptedModulesInInteraction: item.exceptedModulesInInteraction,
                hasWarning: item.hasWarning,
                onTap: item.onTap
            )
        }
    }

    public func buildDetailsBlocks(_ list: [DetailsBlock]) {
        list.forEach { [unowned self] block in
            let stack = getVerticalStack()
            if block.groups.count == 1 && block.groups[0].items.count == 1 {
                let line = block.groups[0].items[0]
                if line.count == 1 {
                    stack.addArrangedSubview(
                        buildDetailItem(from: line[0])
                    )
                }
            } else {
                stack.addArrangedSubviewList(
                    views: block.groups.reduce(into: [UIView]()) { views, group in
                        var lines = [UIView]()
                        if let header = group.header {
                            let headerSection = builder.headerSection(with: header)
                            lines.append(headerSection)
                        } else if let customHeader = group.customHeader {
                            lines.append(customHeader)
                        }

                        if let title = group.title {
                            let sectionTitle = builder.sectionTitle(with: title, andExtra: group.extraView, hasInteraction: group.titleHasInteraction)
                            lines.append(sectionTitle)
                        }

                        if group.tags.count > 0 {
                            let tagsView = builder.buildTags(group.tags)
                            lines.append(tagsView)
                        }

                        lines.append(contentsOf: group.items.map { line in
                            builder.line(
                                views: line.map { detail in
                                    buildDetailItem(from: detail)
                                },
                                distribuition: .fillEqually
                            )
                        })

                        views += lines
                    }
                )
            }
            self.blocksViews.append(stack)
            self.containerView.addSubview(stack)
        }
    }

    @objc private func tapped() {
        print("tapped")
    }
}
