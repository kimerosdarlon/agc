//
//  ColoredTagGroupView.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 04/08/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import UIKit

public class ColoredTagGroupView: UICollectionView {

    enum Section {
        case main
    }

    public struct ColoredTag: Hashable {
        public let label: String
        public let color: UIColor

        public init(label: String, color: UIColor) {
            self.label = label
            self.color = color
        }
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ColoredTag>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ColoredTag>
    private var snapShot: Snapshot?
    private var qualificationDataSource: DataSource?
    private let builder = GenericDetailBuilder()
    private var sizeCalculator: TagSizeDelegate?

    public init(tags: [ColoredTag], containerBackground: UIColor = .appBackgroundCell) {
        let layout = FlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        backgroundColor = containerBackground
        qualificationDataSource = makeDatasource(collection: self)
        dataSource = qualificationDataSource
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
        showsHorizontalScrollIndicator = false
        snapShot = Snapshot()
        snapShot?.appendSections([.main])
        setTags(tags)
    }

    public func setTags(_ tags: [ColoredTag]) {
        snapShot?.deleteAllItems()
        sizeCalculator = TagSizeDelegate(itens: tags.map { $0.label })
        delegate = sizeCalculator
        snapShot?.appendSections([.main])
        snapShot?.appendItems(tags)
        qualificationDataSource?.apply(snapShot!, animatingDifferences: false, completion: nil)
        reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeDatasource(collection: UICollectionView ) -> DataSource {
        return DataSource(collectionView: collection) {(collectionView, indexPath, tag) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TagCell.identifier,
                for: indexPath) as! TagCell
            cell.textLabel.text = tag.label
            cell.contentView.backgroundColor = tag.color
            return cell
        }
    }
}
