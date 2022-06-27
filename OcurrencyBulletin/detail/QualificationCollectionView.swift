//
//  QualificationCollectionView.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 02/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class QualificationCollectionView: UICollectionView {

    enum Section {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    private var snapShot: Snapshot?
    private var qualificationDataSource: DataSource?
    private let builder = GenericDetailBuilder()
    private var sizeCalculator: CollectionViewSizeDelegate?
    private let backGroundCell: UIColor
    init(qualification: [String], backGroundCell: UIColor = .appBlue ) {
        self.backGroundCell = backGroundCell
        let layout = FlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        register(QualificationCell.self, forCellWithReuseIdentifier: QualificationCell.identifier)
        backgroundColor = .appBackgroundCell
        qualificationDataSource = makeDatasource(collection: self)
        dataSource = qualificationDataSource
        sizeCalculator = CollectionViewSizeDelegate(itens: qualification )
        delegate = sizeCalculator
        snapShot = Snapshot()
        snapShot?.appendSections([.main])
        snapShot?.appendItems(qualification)
        qualificationDataSource?.apply(snapShot!, animatingDifferences: true, completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeDatasource(collection: UICollectionView ) -> DataSource {
        return DataSource(collectionView: collection) {(collectionView, indexPath, qualification) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: QualificationCell.identifier,
                for: indexPath) as! QualificationCell
            cell.textLabel.text = qualification
            cell.contentView.backgroundColor = self.backGroundCell
            return cell
        }
    }
}
