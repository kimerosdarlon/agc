//
//  CollectionViewSizeDelegate.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 02/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class CollectionViewSizeDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    private var itens: [String]
    init(itens: [String]) {
        self.itens = itens
        super.init()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = itens[indexPath.item]
        let attr = [NSAttributedString.Key.font: UIFont.robotoMedium.withSize(12)]
        let title = NSString(string: text)
        let size = CGSize(width: 1000, height: 20)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        return CGSize(width: estimateFrame.width + 16, height: 28 )
    }
}
