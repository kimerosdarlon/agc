//
//  TagGroupView.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 07/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class TagGroupView: UICollectionView {

    enum Section {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    private var snapShot: Snapshot?
    private var qualificationDataSource: DataSource?
    private let builder = GenericDetailBuilder()
    private var sizeCalculator: TagSizeDelegate?
    private let backGroundCell: UIColor
    private var tagBordered: Bool = false

    public init(tags: [String], backGroundCell: UIColor = .appBlue, containerBackground: UIColor = .appBackgroundCell, tagBordered: Bool = false) {
        self.backGroundCell = backGroundCell
        let layout = FlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        backgroundColor = containerBackground
        self.tagBordered = tagBordered
        qualificationDataSource = makeDatasource(collection: self)
        dataSource = qualificationDataSource
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
        showsHorizontalScrollIndicator = false
        snapShot = Snapshot()
        snapShot?.appendSections([.main])
        setTags(tags)
    }

    public func setTags(_ tags: [String]) {
        snapShot?.deleteAllItems()
        sizeCalculator = TagSizeDelegate(itens: tags)
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
            cell.textLabel.text = tag
            if self.tagBordered {
                cell.contentView.layer.borderWidth = 0.5
                cell.textLabel.textColor = .appCellLabel
            } else {
                cell.textLabel.textColor = .white
                cell.contentView.backgroundColor = self.backGroundCell
            }
            return cell
        }
    }
}
