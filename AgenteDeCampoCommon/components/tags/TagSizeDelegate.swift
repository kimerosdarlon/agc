//
//  CollectionViewSizeDelegate.swift
//  AgenteDeCampoCommon
//
//  Created by Ramires Moreira on 08/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class TagSizeDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    private var items: [String]
    public init(itens: [String]) {
        self.items = itens
        super.init()
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = items[indexPath.item]
        let attr = [NSAttributedString.Key.font: UIFont.robotoMedium.withSize(12)]
        let title = NSString(string: text)
        let size = CGSize(width: 1000, height: 20)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        return CGSize(width: estimateFrame.width + 16, height: 28 )
    }
}
