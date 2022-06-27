//
//  EquipmentGroupCollectionView.swift
//  CAD
//
//  Created by Samir Chaves on 09/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

protocol EquipmentGroupDelegate: class {
    func didSelectAEquipmentGroup(_ group: EquipmentGroup)
}

class EquipmentGroupCollectionView: UICollectionView {
    weak var equipmentsDelegate: EquipmentGroupDelegate?
    private var isInteractable = false

    enum Section {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, EquipmentGroup>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, EquipmentGroup>
    private var snapShot: Snapshot?
    private var qualificationDataSource: DataSource?
    private let builder = GenericDetailBuilder()
    private var equipmentsGroupsViewModel: EquipmentGroupViewModel

    init(equipments: [Equipment], isInteractable: Bool = true) {
        let layout = FlowLayout()
        equipmentsGroupsViewModel = EquipmentGroupViewModel(equipments: equipments)
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        self.isInteractable = isInteractable
        register(EquipmentCollectionViewCell.self, forCellWithReuseIdentifier: EquipmentCollectionViewCell.identifier)
        backgroundColor = .clear
        qualificationDataSource = makeDatasource(collection: self)
        dataSource = qualificationDataSource
        delegate = self
        snapShot = Snapshot()
        snapShot?.appendSections([.main])
        snapShot?.appendItems(equipmentsGroupsViewModel.groups)
        qualificationDataSource?.apply(snapShot!, animatingDifferences: false, completion: nil)
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeDatasource(collection: UICollectionView ) -> DataSource {
        return DataSource(collectionView: collection) {(collectionView, indexPath, group) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EquipmentCollectionViewCell.identifier,
                for: indexPath
            ) as! EquipmentCollectionViewCell
            cell.configure(with: group)
            if !self.isInteractable {
                cell.contentView.backgroundColor = .clear
                cell.contentView.layer.borderWidth = 1
                cell.contentView.layer.borderColor = UIColor.appTitle.cgColor.copy(alpha: 0.4)
            }
            return cell
        }
    }
}

extension EquipmentGroupCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isInteractable {
            return .init(width: 220, height: 70)
        } else {
            return .init(width: 220, height: 60)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let group = qualificationDataSource?.itemIdentifier(for: indexPath) {
            equipmentsDelegate?.didSelectAEquipmentGroup(group)
        }
    }
}
