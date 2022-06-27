//
//  FlowLayout.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 02/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

public class FlowLayout: UICollectionViewFlowLayout {

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        guard scrollDirection == .vertical else { return layoutAttributes }

        // Filter attributes to compute only cell attributes
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })
        // Group cell attributes by row (cells with same vertical center) and loop on those groups
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 }) {
            // Set the initial left inset
            var leftInset = sectionInset.left

            // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
                //                attribute.frame = attribute.frame.offsetBy(dx: 0, dy: minY - attribute.frame.origin.y)
            }
        }
        var collectionLine = 0

        layoutAttributes.reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
            guard $1.representedElementCategory == .cell else { return $0 }
            return $0.merging([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                ($0.0 < $1.0 ? $0.0 : $1.0, $0.1 + $1.1)
            }
        }
        .values.forEach { minY, line in
            collectionLine += 1
            line.forEach {
                $0.frame = $0.frame.offsetBy(
                    dx: 0,
                    dy: minY - $0.frame.origin.y
                )
            }
        }

        return layoutAttributes
    }

}
