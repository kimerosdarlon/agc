//
//  VehicleDetailHeaderCollectionView.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 01/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class VehicleDetailHeaderCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    var headers = [String]()
    private var builders = [ActionBuilder]()
    var data = [[ItemDetail]]() {
        didSet {
            reloadData()
        }
    }
    var lastUpdate = ""

    let identifier = String(describing: VehicleHeaderCollectionViewCell.self)
    let sectionIdentifier = String(describing: SectionHeaderView.self)

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = FlowLayout()
        layout.sectionInset.left = 8
        layout.sectionInset.right = 8
        super.init(frame: frame, collectionViewLayout: layout)
        register(VehicleHeaderCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sectionIdentifier)
        delegate = self
        dataSource = self
        backgroundColor = .appBackground
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! VehicleHeaderCollectionViewCell
        let item = data[indexPath.section][indexPath.item]
        cell.configure(using: item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = data[indexPath.section][indexPath.item]
        let columnWidth = (collectionView.frame.width - 30)/3
        var adjusteFactor: CGFloat = 0
        if item.colunms.isEqual(to: 2) {
            adjusteFactor = 9
        } else if item.colunms.isEqual(to: 1.5) {
            adjusteFactor = 6
        }
        let width = columnWidth * item.colunms + adjusteFactor
        let attr = [NSAttributedString.Key.font: UIFont.robotoRegular.withSize(13)]
        let title = NSString(string: item.detail ?? "")
        let size = CGSize(width: width - 40, height: 1000)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        return .init(width: width, height: estimateFrame.height + 25)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 22, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 35)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionIdentifier, for: indexPath) as! SectionHeaderView
        let index = min(indexPath.section, headers.count - 1)
        sectionHeader.titleLabel.text = headers[index]
        if indexPath.section == 0 {
            sectionHeader.detailLabel.text = lastUpdate
        }
        return sectionHeader
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = data[indexPath.section][indexPath.item]

        if item.hasInteraction, let detail = item.detail {
            let builder = ActionBuilder(text: detail, hasMapInteraction: item.hasMapInteraction)
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
                let feedback = UISelectionFeedbackGenerator()
                feedback.prepare()
                feedback.selectionChanged()
                return builder.createContextMenu()
            }
        }
        return nil
    }
}
