//
//  OccurencyBulletionDetailTemplateViewController.swift
//  OcurrencyBulletin
//
//  Created by Ramires Moreira on 02/07/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import UIKit

class BulletionDetailTemplateViewController: UIViewController {

    private let alertView = BulletimAlertView()
    var viewModel: OcurrencyBulletinDetailViewModel!
    var expandedIndexPaths = [IndexPath]()

    private var table: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: CGFloat.leastNormalMagnitude))
        table.enableAutoLayout()
        table.backgroundColor = .appBackground
        return table
    }()

    weak var delegate: UITableViewDelegate? {
        didSet {
            table.delegate = delegate
        }
    }

    weak var dataSource: UITableViewDataSource? {
        didSet {
            table.dataSource = dataSource
        }
    }

    init(viewModel: OcurrencyBulletinDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    func registerCell(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        table.register(cellClass, forCellReuseIdentifier: identifier)
    }

    func reloadData() {
        table.reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        view.addSubview(alertView)
        alertView.enableAutoLayout()
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            alertView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 2),
            alertView.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 3),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: alertView.trailingAnchor, multiplier: 3),
            table.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            table.topAnchor.constraint(equalToSystemSpacingBelow: alertView.bottomAnchor, multiplier: 1),
            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: table.bottomAnchor, multiplier: 1)
        ])
    }
}
