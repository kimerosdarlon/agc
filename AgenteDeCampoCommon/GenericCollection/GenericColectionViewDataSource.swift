//
//  GenericColectionViewDataSource.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class GenericColectionViewDataSource: NSObject, UICollectionViewDataSource {

    public var data: [[ItemDetail]]
    public let identifier: String

    public init(data: [[ItemDetail]], cellIdentifier: String) {
        self.data = data
        self.identifier = cellIdentifier
        super.init()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        var count = 0
        for section in data where !section.isEmpty {
            count += 1
        }
        return count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath ) as! GenericCollectionViewCell
        cell.configure(using: data[indexPath.section][indexPath.item])
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var id = String(describing: GenericCollectionFooterView.self)
        let isHeader = kind.elementsEqual(UICollectionView.elementKindSectionHeader)
        if isHeader {
            id = String(describing: SectionSeparatorView.self)
        }
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath)
        if isHeader {
            return sectionHeaderView as! SectionSeparatorView
        }
        return sectionHeaderView as! GenericCollectionFooterView
    }

}

public class SectionSeparatorView: UICollectionReusableView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .appBackground
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GenericCollectionFooterView: UICollectionReusableView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .appBackground
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
