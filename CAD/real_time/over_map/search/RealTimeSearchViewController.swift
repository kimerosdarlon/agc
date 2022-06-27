//
//  RealTimeSearchViewController.swift
//  CAD
//
//  Created by Samir Chaves on 06/07/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class RealTimeSearchViewController: UIViewController {

    weak var resultsDelegate: RTSearchResultsTableDelegate?

    private let searchInput = TextFieldComponent(placeholder: "", label: "").enableAutoLayout()
    private let searchService = RTSearchService.shared
    private let resultsTableView = RTSearchResultsTableView().enableAutoLayout()

    private let debouncer = Debouncer(timeInterval: 0.3)

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        searchInput.textField.addTarget(self, action: #selector(didQueryChange(_:)), for: .editingChanged)
        searchInput.textField.addTarget(self, action: #selector(didEndEditingSearch), for: .editingDidEnd)
        resultsTableView.resultsDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        if UserStylePreferences.theme == .dark {
            blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = view.bounds
        view.addSubview(effectView)

        view.addSubview(searchInput)
        view.addSubview(resultsTableView)

        searchInput.textField.layer.cornerRadius = 20
        let backButton = searchInput.textField
            .buildLeftButton(
                iconName: "chevron.left",
                color: UIColor.appTitle.withAlphaComponent(0.5),
                size: 40,
                containerFrame: .init(x: 0, y: 0, width: 50, height: 40),
                position: .init(x: 10, y: 5)
            )
        backButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchInput.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: -17),
            searchInput.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 23),
            searchInput.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -23),

            resultsTableView.topAnchor.constraint(equalTo: searchInput.bottomAnchor, constant: 20),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: resultsTableView.bottomAnchor, multiplier: 0)
        ])

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didShowKeyboard(_:)), name: UIWindow.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(didHideKeyboard(_:)), name: UIWindow.keyboardDidHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchInput.textField.becomeFirstResponder()
    }

    @objc private func didShowKeyboard(_ notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIWindow.keyboardFrameBeginUserInfoKey] as? CGRect {
            resultsTableView.contentInset = .init(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func didHideKeyboard(_ notification: Notification) {
        resultsTableView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    @objc func didQueryChange(_ textField: UITextField) {
        guard let query = textField.text else { return }
        let results = searchService.search(by: query)
        debouncer.renewInterval()
        debouncer.handler = {
            self.resultsTableView.updateResults(results: results, forQuery: query)
        }
    }

    @objc func closeModal() {
        dismiss(animated: true)
    }

    @objc func didEndEditingSearch() {
//        dismiss(animated: true)
    }
}

extension RealTimeSearchViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushAnimatorController(duration: 0.2, animationType: .present)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushAnimatorController(duration: 0.1, animationType: .dismiss)
    }
}

extension RealTimeSearchViewController: RTSearchResultsTableDelegate {
    func didSelectAnOccurrenceResult(_ occurrence: SimpleOccurrence) {
        resultsDelegate?.didSelectAnOccurrenceResult(occurrence)
        if let currentQuery = searchInput.textField.text {
            resultsTableView.storeRecentSearch(query: currentQuery)
        }
        self.resignFirstResponder()
        dismiss(animated: true)
    }

    func didSelectATeamResult(_ team: NonCriticalTeam) {
        resultsDelegate?.didSelectATeamResult(team)
        if let currentQuery = searchInput.textField.text {
            resultsTableView.storeRecentSearch(query: currentQuery)
        }
        self.resignFirstResponder()
        dismiss(animated: true)
    }

    func didSelectARecentSearch(_ query: String) {
        resultsDelegate?.didSelectARecentSearch(query)
        searchInput.textField.text = query
        let results = searchService.search(by: query)
        resultsTableView.updateResults(results: results, forQuery: query)
    }
}
