//
//  RecentsTableViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 13/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoModule
import AgenteDeCampoCommon
import CoreDataModels

class RecentsTableViewController: UIViewController {

    private var service: RecentsDataSource!
    private var clearButton: UIBarButtonItem!
    private var selectedIndexPaths = [IndexPath]()

    private let table: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.enableAutoLayout()
        table.backgroundColor = .appBackground
        table.register(HintTableViewCell.self, forCellReuseIdentifier: "recentsCell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        service = RecentsDataSource(table: table)
        table.delegate = self
        view.addSubview(table)
        table.fillSuperView()
        title = self.settingsTitle()
        editButtonItem.tintColor = .appBlue
        editButtonItem.action = #selector(toggleEditMode)
        navigationItem.setRightBarButton(editButtonItem, animated: false)
        setupToobar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        service.reloadData()
        table.delegate = self
        table.dataSource = service
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        table.delegate = nil
        table.dataSource = nil
    }

    func setupToobar() {
        clearButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearAllSelected(_:)))
        clearButton.isEnabled = false
        let clearAll = UIBarButtonItem(title: "apagar todos", style: .plain, target: self, action: #selector(clearAll(_:)))
        clearAll.tintColor = .systemRed
        let centerSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setToolbarItems([clearButton, centerSpace, clearAll], animated: true)
        let apperance = UIToolbarAppearance()
        apperance.backgroundColor = .appBackground
        self.navigationController!.toolbar.standardAppearance = apperance
        self.navigationController!.toolbar.compactAppearance = apperance
    }

    @objc
    func toggleEditMode() {
        isEditing.toggle()
        self.navigationController?.setToolbarHidden(!self.isEditing, animated: true)
        UIView.animate(withDuration: 0.2) {
            self.tabBarController!.tabBar.alpha = self.isEditing ? 0 : 1
        }
        (navigationController!.toolbar as! CustomToolBar).state = isEditing ? .visible : .hidden

        if !isEditing {
            selectedIndexPaths.removeAll()
            clearButton.isEnabled = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if isEditing {
            toggleEditMode()
        }
    }

    @objc
    func clearAllSelected(_ sender: UIBarButtonItem) {
        service.deleteAll(in: selectedIndexPaths)
        self.toggleEditMode()
    }

    @objc
    func clearAll(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "Apagar tudo?", message: "Deseja apagar o histórico de consultas? Essa ação não pode ser desfeita.", preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: "apagar", style: .destructive) { (_) in
            self.service.clearAll()
            self.toggleEditMode()
        }
        let cancel = UIAlertAction(title: "cancelar", style: .cancel, handler: nil)
        controller.addAction(confirm)
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)

    }

    override var isEditing: Bool {
        didSet {
            table.allowsSelectionDuringEditing = false
            table.allowsMultipleSelectionDuringEditing = isEditing
            table.setEditing(isEditing, animated: true)
        }
    }
}

extension RecentsTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            clearButton.isEnabled = true
            selectedIndexPaths.append(indexPath)
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        var recent = service.object(at: indexPath)
        if let controller = ModuleService.getController(for: recent.module, search: recent.text, query: recent.searchQuery ) {
            recent.date = Date()
            service.save(recent)
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing {
            selectedIndexPaths.removeAll(where: {$0 == indexPath})
            clearButton.isEnabled = !selectedIndexPaths.isEmpty
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "remover") { (_, _, handler) in
            self.service.delete(at: indexPath)
            handler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

extension RecentsTableViewController: SettingsOption {

    func settingsTitle() -> String {
        "Consultas recentes"
    }

    func settingsSubTitle() -> String {
        ""
    }

    func settingsIcon() -> UIImage {
        UIImage(systemName: "timer")!
    }

    func accesoryView() -> UIView? {
        nil
    }

    func shouldPresent() -> Bool {
        true
    }
}
