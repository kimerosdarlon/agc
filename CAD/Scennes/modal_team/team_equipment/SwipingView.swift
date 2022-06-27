//
//  SwipingView.swift
//  CAD
//
//  Created by Samir Chaves on 09/02/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class SwipingViewController: UICollectionViewController {
    private var equipments = [Equipment]()

    init(equipments: [Equipment], layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        self.equipments = equipments
        self.collectionView.showsHorizontalScrollIndicator = false
        pageControl.addTarget(self, action: #selector(pageDidChange(_:)), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func pageDidChange(_ sender: UIPageControl) {
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .left, animated: true)
    }

    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = equipments.count
        pc.currentPageIndicatorTintColor = .appTitle
        pc.pageIndicatorTintColor = UIColor.appTitle.withAlphaComponent(0.5)
        return pc
    }()

    fileprivate func setupBottomControls() {
        view.addSubview(pageControl.enableAutoLayout())

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(x / view.frame.width)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomControls()
        view.backgroundColor = .appBackground
        collectionView.backgroundColor = .appBackground
        self.collectionView.register(EquipmentCell.self, forCellWithReuseIdentifier: "cellId")
        self.collectionView.isPagingEnabled = true
    }
}

extension SwipingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return equipments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! EquipmentCell

        let equipment = equipments[indexPath.item]
        cell.configure(with: equipment)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
