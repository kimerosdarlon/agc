//
//  ResultController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 24/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon
import CoreDataModels

class SearchResultController: UITableViewController {

    private let modulos = ModuleService.allWithRoles( UserService.shared.getCurrentUser()?.roles )
    private var filteredData = [HintCellModel]()
    private static let maxRecents = 5
    private var recents = Stack<HintCellModel>(limit: SearchResultController.maxRecents)
    weak var delegate: SearchDelegate?
    weak var filterDelegate: HomeCollectionViewDelegateDataSourceDelegate? {
        didSet {
            self.footer.delegate = filterDelegate
        }
    }
    private var recentsService = RecentsDataSource()
    private let emptyCell = HintCellModel(text: "Sem resultados", module: "", iconName: "hourglass", date: Date())

    lazy var recentesFooterButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Ver mais", for: .normal)
        btn.frame = .init(x: 0, y: 0, width: 100, height: 22)
        btn.setTitleColor(.appBlue, for: .normal)
        btn.titleLabel?.font = UIFont.robotoRegular.withSize(14)
        btn.addTarget(self, action: #selector(didSelectSeeMore), for: .touchUpInside)
        return btn
    }()
    lazy var footer = ModuleCollectionViewFooter(frame: .init(x: 0, y: 0, width: view.frame.width, height: 300))

    override init(style: UITableView.Style) {
        super.init(style: style)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HintTableViewCell.self, forCellReuseIdentifier: "hintCell")
        tableView.enableAutoLayout()
        tableView.fillSuperView()
        tableView.backgroundColor = .appBackground
        NotificationCenter.default.addObserver(self, selector: #selector(loadRecents), name: .clearRecents, object: nil)
        footer.configure(using: modulos)
        let myView = UIView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 300))
        myView.backgroundColor = .red
        tableView.tableFooterView = footer
    }

    @objc
    func loadRecents() {
        recents.clear()
        recentsService.getAll().forEach({recents.push($0)})
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        tableView.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        loadRecents()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.isEmpty ? recents.count : filteredData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath) as! HintTableViewCell
        let item = filteredData.isEmpty ? recents[indexPath.row] : filteredData[indexPath.item]
        cell.configure(using: item, expanded: false)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var item = filteredData.isEmpty ? recents[indexPath.item] : filteredData[indexPath.item]
        item.iconName = "clock"
        item.date = Date()
        tableView.reloadData()
        if let controller = ModuleService.getController(for: item.module, search: item.text, query: item.searchQuery) {
            recentsService.save(item)
            loadRecents()
            delegate?.present(controller: controller, completion: nil)
        }
    }

    func filter(search: String) {
        do {
            let icon = "magnifyingglass"
            defer { tableView.reloadData() }
            if search.isEmpty {
                filteredData = []
            } else {
                filteredData = modulos.filter({$0.matches(in: search)})
                    .map({ HintCellModel(text: search, module: $0.name, iconName: icon, date: Date()) })
                var recentsMatched = recents.filter({$0.text.lowercased().starts(with: search.lowercased())})
                recentsMatched = recentsMatched - filteredData
                recentsMatched.forEach({ filteredData.append($0) })
                if filteredData.isEmpty { filteredData.append( emptyCell ) }
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.enableAutoLayout()
        label.textColor = .appCellLabel
        view.addSubview(label)
        view.backgroundColor = .appBackground
        label.left(view, mutiplier: 2)
        view.bottom(to: label.bottomAnchor, 1)
        let firstHeader = filteredData.isEmpty ? "Consultas recentes" : "Sugestões"
        label.text = [ firstHeader, "Módulos"][section]
        return view
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let recentsIsMoreThanMax = recentsService.getAll().count > SearchResultController.maxRecents
        if filteredData.isEmpty && recentsIsMoreThanMax {
            return recentesFooterButton
        }
        return nil
    }

    @objc
    func didSelectSeeMore(_ sender: UIButton) {
        let controller = RecentsTableViewController()
        delegate?.present(controller: controller, completion: nil)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "remover") { (_, _, _) in
            self.recentsService.delete(at: indexPath)
            self.recents.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .left)
            if self.recentsService.getAll().count > self.recents.count {
                let count = self.recents.count
                let index = IndexPath.init(row: count, section: 0)
                let recent = self.recentsService.object(at: index )
                self.recents.insert(recent, at: count)
                tableView.insertRows(at: [IndexPath.init(row: count, section: 0)], with: .bottom)
                if self.recentsService.getAll().count == self.recents.count {
                    self.recentesFooterButton.removeFromSuperview()
                }
            }
        }
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

}
