//
//  File.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 24/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

class SearchController: UISearchController, UISearchBarDelegate {

    var tableView: UITableView!

    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        definesPresentationContext = true
        searchBar.delegate  = self
        hidesNavigationBarDuringPresentation = true
        searchBar.searchTextField.backgroundColor = .appBackground
        obscuresBackgroundDuringPresentation = true
//        searchBar.showsBookmarkButton = true
//        let mic = UIImage(systemName: "mic")?.withTintColor(.appBlue, renderingMode: .alwaysOriginal)
//        searchBar.setImage(mic, for: .bookmark, state: .normal)
        searchBar.tintColor = .appBlue
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .appBackgroundCell
        searchBar.placeholder = "Consulta geral"
        searchBar.setImage(nil, for: .search, state: .normal)
        showsSearchResultsController = true
        let searchTextField = self.searchBar.value(forKey: "searchField") as! UITextField
        searchTextField.leftViewMode = .never
        view.backgroundColor = .appBackground
        modalPresentationCapturesStatusBarAppearance = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.searchTextField.text = searchText.uppercased()
        if let resultController = searchResultsController as? SearchResultController {
            resultController.filter(search: searchText)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
          if let resultController = searchResultsController as? SearchResultController {
            resultController.tableView.overrideUserInterfaceStyle = UserStylePreferences.theme.style
            resultController.view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        }
        if let presentingVC = self.presentingViewController {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.view.frame = presentingVC.view.frame
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let resultController = searchResultsController as? SearchResultController {
            resultController.filter(search: "")
        }
    }
}
