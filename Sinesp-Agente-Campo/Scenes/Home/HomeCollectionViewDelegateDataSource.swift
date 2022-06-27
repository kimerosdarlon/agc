//
//  HomeCollectionViewDelegateDataSource.swift
//  RestClient
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon

class HomeCollectionViewDelegateDataSource: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    weak var delegate: HomeCollectionViewDelegateDataSourceDelegate?
    private var modulos = ModuleService.allWithRoles(UserService.shared.getCurrentUser()?.roles)

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modulos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ModuloCollectionViewCell.identifier, for: indexPath) as! ModuloCollectionViewCell
        cell.configure(with: modulos[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 50) / 2
        let height = width * 0.7
        return .init(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 18.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let kind = UICollectionView.elementKindSectionHeader
        let identifier = CollectionHeaderView.identifier
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        header.frame.size.height = HomeCollectionView.headerHeight
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let module = modulos[indexPath.item]
        if !module.isEnable {
            delegate?.show("Use a barra de pesquisa, para buscar mandados. A tela de filtros ainda está em desenvolvimento")
            return
        }
        if let controller = modulos[indexPath.item].filterController {
            let filterController = controller.init(params: [:])
            delegate?.present(viewController: filterController)
        } else {
            delegate?.show("Use a barra de pesquisa, para buscar mandados. A tela de filtros ainda está em desenvolvimento")
        }
    }
}
