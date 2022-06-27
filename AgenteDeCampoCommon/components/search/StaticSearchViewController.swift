//
//  GenericSearchViewController.swift
//  CAD
//
//  Created by Samir Chaves on 14/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

public typealias SearchResult = (key: String, value: String)

public class StaticSearchViewController: UIViewController, UIViewControllerTransitioningDelegate {
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    weak var delegate: StaticSearchViewDelegate?
    private var textField: UITextField!
    private var searchQuery: String = ""
    private var emptyFeedback: String
    private let searchField = UISearchTextField(frame: .zero).enableAutoLayout().height(40)
    private let resultListView: UITableView = {
        let view = UITableView()
        view.enableAutoLayout()
        view.register(StaticSearchResultTableCell.self, forCellReuseIdentifier: StaticSearchResultTableCell.identifier)
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
    private let feedbackLabel = UILabel.build(withSize: 14, alpha: 0.5, weight: .bold, alignment: .center)

    private var data = [SearchResult]()
    private var filteredData = [SearchResult]()

    public var onSelect: (SearchResult) -> Void = { _ in }

    public init(inputText: UITextField, data: [SearchResult], emptyFeedback: String = "Não há dados disponíveis") {
        self.emptyFeedback = emptyFeedback
        super.init(nibName: nil, bundle: nil)
        self.textField = inputText
        modalPresentationStyle = .custom
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = 15
        self.data = data
        self.filteredData = data

        searchField.placeholder = textField.placeholder
        searchField.addTarget(self, action: #selector(self.searchChanged(_:)), for: .editingChanged)
    }

    @objc func searchChanged(_ textField: UITextField) {
        self.searchQuery = textField.text ?? ""
        if self.searchQuery.isEmpty {
            self.resetData()
        } else {
            self.filterData()
        }
        self.resultListView.reloadData()
    }

    fileprivate func filterData() {
        filteredData = data.filter { item in
            item.value.lowercased().contains(self.searchQuery.lowercased().trimmingCharacters(in: .whitespaces))
        }
    }

    fileprivate func resetData() {
        filteredData = data
    }

    @objc func resetSearch() {
        let result = (key: "", value: "")
        textField.text = result.value
        delegate?.didSelectResultItem(result)
        onSelect(result)
        self.dismiss(animated: true, completion: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        transitionDelegate = SearchPresentationManager()
        transitioningDelegate = transitionDelegate

        view.addSubview(feedbackLabel)
        view.addSubview(searchField)
        view.addSubview(resultListView)
        view.addSubview(clearBtn)
        clearBtn.addTarget(self, action: #selector(self.resetSearch), for: .touchUpInside)
        resultListView.delegate = self
        resultListView.dataSource = self
        searchField.delegate = self
//
//        if data.isEmpty {
//            feedbackLabel.text = emptyFeedback
//            resultListView.isHidden = true
//            feedbackLabel.isHidden = false
//        } else {
//            resultListView.isHidden = false
//            feedbackLabel.isHidden = true
//        }

        let padding: CGFloat = 10
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            feedbackLabel.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 20),
            feedbackLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            searchField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
            searchField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            searchField.trailingAnchor.constraint(equalTo: clearBtn.leadingAnchor, constant: -padding),
            clearBtn.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            clearBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),

            resultListView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: padding),
            resultListView.bottomAnchor.constraint(equalToSystemSpacingBelow: safeArea.bottomAnchor, multiplier: 1),
            resultListView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            resultListView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.searchField.becomeFirstResponder()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StaticSearchViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StaticSearchResultTableCell.identifier, for: indexPath) as! StaticSearchResultTableCell
        let value = self.filteredData[indexPath.item].value
        cell.configure(withValue: value, isSelected: false)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = self.filteredData[indexPath.item]
        textField.text = result.value
        delegate?.didSelectResultItem(result)
        onSelect(result)
        self.dismiss(animated: true, completion: nil)
    }
}
