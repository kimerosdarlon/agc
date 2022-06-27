//
//  GenericCollectionViewDelegate.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class GenericCollectionViewDelegateFlowLayout: NSObject, UICollectionViewDelegateFlowLayout {

    public var data: [[ItemDetail]]

    public init(data: [[ItemDetail]]) {
        self.data = data
        super.init()
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 15
        let item = data[indexPath.section][indexPath.item]
        let windowWitdh = UIScreen.main.bounds.width
        let width = (( windowWitdh / 3 ) - space ) * item.colunms
        let attr = [NSAttributedString.Key.font: UIFont.robotoRegular.withSize(13)]
        let title = NSString(string: item.detail ?? "" )
        let size = CGSize(width: width, height: 1000)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        return .init(width: width, height: estimateFrame.height + 30)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return .zero
        }
        return .init(width: collectionView.frame.width, height: 16)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
}
