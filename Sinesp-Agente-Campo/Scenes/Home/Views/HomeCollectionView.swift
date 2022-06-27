//
//  HomeCollectionView.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 23/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class HomeCollectionView: UICollectionView {

    static let headerHeight: CGFloat = 40

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        (layout as? UICollectionViewFlowLayout)?.headerReferenceSize =  CGSize(width: frame.size.width, height: HomeCollectionView.headerHeight)
        register(ModuloCollectionViewCell.self, forCellWithReuseIdentifier: ModuloCollectionViewCell.identifier)
        register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.identifier)
        enableAutoLayout()
        backgroundColor = .appBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
