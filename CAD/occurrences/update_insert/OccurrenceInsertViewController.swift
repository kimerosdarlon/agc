//
//  OccurrenceInsertViewController.swift
//  CAD
//
//  Created by Samir Chaves on 21/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit

class OccurrenceInsertViewController<M: Codable>: UIViewController {
    weak var updateDelegate: OccurrenceDataUpdateDelegate?

    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    private let titleLabel = UILabel.build(withSize: 17, weight: .medium, color: .appTitle, alignment: .center)
    private let nameLabel = UILabel.build(withSize: 19, weight: .bold, color: .appTitle, alignment: .left)

    private let loadingIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView().enableAutoLayout()
        loader.style = .large
        loader.backgroundColor = UIColor.appBackground.withAlphaComponent(0.6)
        return loader
    }()

    internal let container = UIScrollView(frame: .zero).enableAutoLayout()

    public override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    public init(name: String) {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom

        transitionDelegate = DefaultModalPresentationManager(heightFactor: 0.9)
        transitioningDelegate = transitionDelegate

        nameLabel.text = name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        view.backgroundColor = .appBackground

        view.addSubview(nameLabel)
        view.addSubview(titleLabel)
        view.addSubview(container)
        view.addSubview(loadingIndicator)

        let saveBarItem = UIBarButtonItem(title: "Salvar", style: .plain, target: self, action: #selector(didTapOnSaveBtn))
        navigationItem.rightBarButtonItem = saveBarItem
        let cancelBarItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(didTapOnCancelBtn))
        cancelBarItem.tintColor = .appRed
        navigationItem.leftBarButtonItem = cancelBarItem

        title = "Criação"

        setupLayout()
    }

    internal func startLoading() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }

    internal func stopLoading() {
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
    }

    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),

            container.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            container.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15)
        ])

        loadingIndicator.fillSuperView()
    }

    internal func didSave() { }

    @objc private func didTapOnSaveBtn() {
        garanteeMainThread {
            self.didSave()
        }
    }

    @objc private func didTapOnCancelBtn() {
        navigationController?.popViewController(animated: true)
    }

    internal func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Salvo com sucesso",
            message: "O objeto foi criado.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: {
                self.updateDelegate?.didSave()
                self.navigationController?.popViewController(animated: true)
            })
        })
        alert.addAction(okAction)
        present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            alert.dismiss(animated: true, completion: {
                self.updateDelegate?.didSave()
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

    internal func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            alert.dismiss(animated: true)
        })
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
