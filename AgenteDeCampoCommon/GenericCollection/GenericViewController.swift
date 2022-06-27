//
//  GenericViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 11/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

open class GenericViewController: UIViewController {

    let data: [[ItemDetail]]
    var table = UITableView(frame: .zero, style: .grouped)
    var contentView: GenericColectionView!
    var contentDelegateFlowLayout: GenericCollectionViewDelegateFlowLayout!
    var contentDataSource: GenericColectionViewDataSource!
    let cellItemtifier = "pieceViewCell"

    public init(data: [[ItemDetail]], title: String) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        self.title = title
        table.register(UITableViewCell.self, forCellReuseIdentifier: "genericCellId")
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        view.backgroundColor = .appBackground
        contentView = GenericColectionView(frame: .zero, collectionViewLayout: FlowLayout())
        contentDelegateFlowLayout = GenericCollectionViewDelegateFlowLayout(data: data)
        contentView.register(GenericCollectionViewCell.self, forCellWithReuseIdentifier: cellItemtifier)
        contentDataSource = GenericColectionViewDataSource(data: data, cellIdentifier: cellItemtifier)
        contentView.delegate = contentDelegateFlowLayout
        contentView.dataSource = contentDataSource
        addSubviews()
        setupConstraints()
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .appBackground
        table.separatorStyle = .none
        contentView.reloadData()
    }

    public func addSubviews() {
        view.addSubview(table)
    }

    public func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        contentView.enableAutoLayout()
        table.enableAutoLayout()
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 2),
            table.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 1),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: table.trailingAnchor, multiplier: 1),
            table.bottomAnchor.constraint(equalToSystemSpacingBelow: safeArea.bottomAnchor, multiplier: 1)
        ])
    }

    open func contentHeight() -> CGFloat {
        return 200
    }
}

extension GenericViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genericCellId", for: indexPath)
        cell.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: cell.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
            cell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.layoutIfNeeded()
        cell.backgroundColor = .appBackground
        return cell
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
