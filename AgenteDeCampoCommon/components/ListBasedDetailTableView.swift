//
//  ListBasedDetailTableView.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 23/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

open class ListBasedDetailCell: UITableViewCell {
    public weak var parentViewController: UIViewController?
    public static let identifier = String(describing: ListBasedDetailCell.self)

    fileprivate var builder = GenericDetailBuilder()

    open var block: DetailsBlock?
    private var padding: UIEdgeInsets = .zero

    private func getVerticalStack(padding: UIEdgeInsets) -> UIStackView {
        let stack = builder.verticalStack(spacing: 15, alignment: .fill, distribution: .fill)
        stack.layoutMargins = padding
        stack.isLayoutMarginsRelativeArrangement = true
        stack.enableAutoLayout()
        stack.backgroundColor = .appBackground
        return stack
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

    public override func prepareForReuse() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    open func getDetailsView() -> UIView {
        guard let block = self.block else { return UIView() }

        let stack = getVerticalStack(padding: padding)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

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
        stack.addArrangedSubview(UIView().enableAutoLayout().height(1))

        return stack
    }

    open func configure(with block: DetailsBlock, padding: UIEdgeInsets) {
        self.padding = padding
        self.block = block
        let detailsView = self.getDetailsView()

        addSubview(detailsView)
        NSLayoutConstraint.activate([
            detailsView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            detailsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom),
            detailsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
            detailsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.right)
        ])
    }
}

public class ListBasedDetailTableView<Cell: ListBasedDetailCell>: UITableView, UITableViewDelegate {
    enum Section {
        case main
    }

    typealias DataSource = UITableViewDiffableDataSource<Section, DetailsBlock>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DetailsBlock>

    private var blocksDataSource: DataSource?

    public var builder: GenericDetailBuilder!
    private var padding: UIEdgeInsets!
    private var spacing: CGFloat = 15
    private var widthMultiplier: CGFloat = 0.925
    private var parentViewController: UIViewController?

    public init(boldFontSize: CGFloat = 13,
                regularFontSize: CGFloat = 16,
                padding: UIEdgeInsets = .init(top: 15, left: 15, bottom: 15, right: 15),
                spacing: CGFloat = 15,
                widthMultiplier: CGFloat = 0.925,
                parentViewController: UIViewController? = nil) {
        self.parentViewController = parentViewController
        let builder = GenericDetailBuilder()
        builder.configurations.regularLabelColor = UIColor.appTitle.withAlphaComponent(0.6)
        builder.configurations.boldLabelColor = .appTitle
        builder.configurations.boldFontSize = boldFontSize
        builder.configurations.regularFontSize = regularFontSize
        builder.configurations.verticalSpacing = 2
        self.builder = builder
        self.padding = padding
        self.spacing = spacing
        self.widthMultiplier = widthMultiplier

        super.init(frame: .zero, style: .plain)

        register(Cell.self, forCellReuseIdentifier: Cell.identifier)

        tableFooterView = UIView()
        delegate = self
        separatorStyle = .none
        estimatedRowHeight = 80
        rowHeight = UITableView.automaticDimension
        backgroundColor = .clear
        allowsSelection = false

        blocksDataSource = makeDataSource()
        dataSource = blocksDataSource
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func apply(blocks: [DetailsBlock]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(blocks)
        blocksDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func makeDataSource() -> DataSource {
        DataSource(
            tableView: self,
            cellProvider: { (tableView, indexPath, block) -> UITableViewCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell
                cell?.parentViewController = self.parentViewController
                cell?.configure(with: block, padding: self.padding)
                return cell
            }
        )
    }
}
