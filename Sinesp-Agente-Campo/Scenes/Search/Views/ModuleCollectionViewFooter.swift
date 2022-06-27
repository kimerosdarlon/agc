//
//  ModuleTableViewCell.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 24/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon

class ModuleCollectionViewFooter: UIView {

    private var modules = [Module]()
    weak var delegate: HomeCollectionViewDelegateDataSourceDelegate?

    private let collection: UICollectionView = {
        let layout = FlowLayout()
        layout.sectionInset.left = 16
        layout.sectionInset.right = 16
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.enableAutoLayout()
        collection.register(RoundedCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: RoundedCollectionViewCell.self))
        collection.backgroundColor = .appBackground
        return collection
    }()

    func configure(using modules: [Module]) {
        self.modules = modules
        addSubview(collection)
        collection.fillSuperView()
        collection.isScrollEnabled = false
        collection.dataSource = self
        collection.delegate = self
        collection.reloadData()
    }

}

extension ModuleCollectionViewFooter: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modules.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RoundedCollectionViewCell.self ), for: indexPath) as! RoundedCollectionViewCell
        cell.textLabel.text = modules[indexPath.item].name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let module = modules[indexPath.item]
        let attr = [NSAttributedString.Key.font: UIFont.robotoMedium.withSize(18)]
        let title = NSString(string: module.name)
        let size = CGSize(width: 1000, height: 20)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        return CGSize(width: estimateFrame.width, height: 28 )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 8, left: 32, bottom: 8, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let clazz = modules[indexPath.item].filterController {
            let controller = clazz.init(params: [:])
            delegate?.present(viewController: controller)
        } else {
            delegate?.show("Use a barra de pesquisa, para buscar mandados. A tela de filtros ainda está em desenvolvimento")
        }
    }

}
