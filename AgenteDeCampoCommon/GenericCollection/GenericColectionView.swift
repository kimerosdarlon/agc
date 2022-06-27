//
//  GenericColectionView.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class GenericColectionView: UICollectionView {

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = .appBackgroundCell
        layer.cornerRadius = 5
        register(SectionSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: SectionSeparatorView.self))
        register(GenericCollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: GenericCollectionFooterView.self))
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize {
        return contentSize
    }

}
