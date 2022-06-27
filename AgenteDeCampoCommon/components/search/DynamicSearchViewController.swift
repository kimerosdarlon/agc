//
//  DynamicSearchViewController.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 28/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public struct DynamicResult<K: Hashable>: Hashable {
    public let key: K
    public let value: String

    public init(key: K, value: String) {
        self.key = key
        self.value = value
    }
}

public class DynamicSearchViewController<K: Hashable>: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    enum Section { case main }

    private typealias DataSource = UITableViewDiffableDataSource<Section, DynamicResult<K>>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DynamicResult<K>>
    private typealias Cell = StaticSearchResultTableCell

    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    private var textField: UITextField!
    private var searchQuery: String = ""
    private var emptyFeedback: String
    private let searchField = UISearchTextField(frame: .zero).enableAutoLayout().height(40)
    private let loadingView = UIActivityIndicatorView()
    private let resultListView: UITableView = {
        let view = UITableView()
        view.enableAutoLayout()
        view.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        view.backgroundColor = .clear
        view.separatorStyle = .none
        return view
    }()
    private let clearBtn: UIButton = {
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.width(70).height(40)
        btn.setTitle("Limpar", for: .normal)
        btn.setTitleColor(.appBlue, for: .normal)
        return btn
    }()
    private let canClean: Bool
    private let feedbackLabel = UILabel.build(withSize: 14, alpha: 0.5, weight: .bold, alignment: .center)

    private var results = [DynamicResult<K>]()
    private var dataSource: DataSource?
    private var snapshot: Snapshot?

    private let debouncer = Debouncer(timeInterval: 0.3)

    public var selected = Set<K>()
    public var onSelect: (DynamicResult<K>?) -> Void = { _ in }
    public var onChangeQuery = { (query: String, completion: ([DynamicResult<K>]) -> Void) in }

    public init(inputText: UITextField, emptyFeedback: String = "Não há dados disponíveis", canClean: Bool = true) {
        self.emptyFeedback = emptyFeedback
        self.canClean = canClean
        super.init(nibName: nil, bundle: nil)
        self.textField = inputText
        modalPresentationStyle = .custom
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = 15

        searchField.placeholder = textField.placeholder
        searchField.addTarget(self, action: #selector(self.searchChanged(_:)), for: .editingChanged)

        dataSource = makeDataSource()
        snapshot = Snapshot()
        resultListView.dataSource = dataSource
        resultListView.delegate = self
    }

    private func startLoading() {
        resultListView.alpha = 0.5
        resultListView.backgroundView = loadingView
        loadingView.startAnimating()
    }

    private func stopLoading() {
        resultListView.alpha = 1
        loadingView.stopAnimating()
        resultListView.backgroundView = nil
    }

    @objc private func searchChanged(_ textField: UITextField) {
        self.searchQuery = textField.text ?? ""
        self.stopLoading()
        self.startLoading()

        debouncer.renewInterval()
        debouncer.handler = {
            self.onChangeQuery(self.searchQuery) { results in
                garanteeMainThread {
                    self.stopLoading()
                    self.results = results
                    self.apply()
                }
            }
        }
    }

    @objc private func resetSearch() {
        textField.text = nil
        onSelect(nil)
        self.dismiss(animated: true, completion: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        transitionDelegate = SearchPresentationManager()
        transitioningDelegate = transitionDelegate

        view.addSubview(feedbackLabel)
        view.addSubview(searchField)
        view.addSubview(resultListView)
        clearBtn.addTarget(self, action: #selector(self.resetSearch), for: .touchUpInside)
        searchField.delegate = self

        let padding: CGFloat = 10
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            feedbackLabel.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 20),
            feedbackLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            searchField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
            searchField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),

            resultListView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: padding),
            resultListView.bottomAnchor.constraint(equalToSystemSpacingBelow: safeArea.bottomAnchor, multiplier: 1),
            resultListView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            resultListView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])

        if canClean {
            view.addSubview(clearBtn)
            NSLayoutConstraint.activate([
                searchField.trailingAnchor.constraint(equalTo: clearBtn.leadingAnchor, constant: -padding),
                clearBtn.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
                clearBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding)
            ])
        } else {
            NSLayoutConstraint.activate([
                searchField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding)
            ])
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let searchField = self?.searchField else { return }
            searchField.becomeFirstResponder()
            self?.searchChanged(searchField)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeDataSource() -> DataSource {
        DataSource(
            tableView: resultListView,
            cellProvider: { (tableView, _, recentQuery) -> Cell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as? Cell
                cell?.configure(withValue: recentQuery.value, isSelected: self.selected.contains(recentQuery.key))
                cell?.backgroundColor = .appBackground
                return cell
            }
        )
    }

    private func apply() {
        snapshot?.deleteAllItems()
        snapshot?.appendSections([.main])
        snapshot?.appendItems(results)
        dataSource?.apply(snapshot!, animatingDifferences: false)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = self.results[indexPath.item]
        textField.text = result.value
        onSelect(result)
        self.dismiss(animated: true, completion: nil)
    }
}
