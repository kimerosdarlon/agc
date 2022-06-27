//
//  OccurrenceUpdateViewController.swift
//  CAD
//
//  Created by Samir Chaves on 03/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import UIKit

public class OccurrenceUpdateViewController<M: Codable>: UIViewController {
    weak var updateDelegate: OccurrenceDataUpdateDelegate?
    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    private let titleLabel = UILabel.build(withSize: 17, weight: .medium, color: .appTitle, alignment: .center)
    private let nameLabel = UILabel.build(withSize: 19, weight: .bold, color: .appTitle, alignment: .left)
    private let versionLabel = UILabel.build(withSize: 14, alpha: 0.8, color: .appTitle, alignment: .right, italic: true)

    private let removeBtn: UIButton = {
        let btn = UIButton(type: .custom).enableAutoLayout()
        let icon = UIImage(systemName: "trash.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("Remover item", for: .normal)
        btn.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 5)
        btn.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 0)
        btn.setImage(icon, for: .normal)
        btn.layer.cornerRadius = 5
        btn.backgroundColor = .appRedAlert
        btn.addTarget(self, action: #selector(didTapOnRemoveButton), for: .touchUpInside)
        return btn
    }()

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

    internal let initialModel: M
    internal var model: M
    internal var remoteModel: M?
    internal let canDelete: Bool
    internal var needUpdateDetails: Bool = false

    public init(model: M, name: String, version: Int, canDelete: Bool) {
        self.initialModel = model
        self.model = model
        self.canDelete = canDelete
        super.init(nibName: nil, bundle: nil)

        if version < 0 {
            versionLabel.isHidden = true
        }

        nameLabel.text = name
        versionLabel.text = "Versão \(version)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        view.backgroundColor = .appBackground

        view.addSubview(nameLabel)
        view.addSubview(versionLabel)
        view.addSubview(titleLabel)
        view.addSubview(container)
        if canDelete {
            view.addSubview(removeBtn)
        }
        view.addSubview(loadingIndicator)

        let saveBarItem = UIBarButtonItem(title: "Salvar", style: .plain, target: self, action: #selector(didTapOnSaveBtn))
        navigationItem.rightBarButtonItem = saveBarItem
        let cancelBarItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(didTapOnCancelBtn))
        cancelBarItem.tintColor = .appRed
        navigationItem.leftBarButtonItem = cancelBarItem

        title = "Edição"

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

        removeBtn.height(40)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),

            versionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            versionLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            container.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            container.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])

        if canDelete {
            NSLayoutConstraint.activate([
                container.bottomAnchor.constraint(equalTo: removeBtn.topAnchor, constant: -15),

                removeBtn.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.8),
                removeBtn.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                removeBtn.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15)
            ])
        } else {
            NSLayoutConstraint.activate([
                container.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15)
            ])
        }

        loadingIndicator.fillSuperView()
    }

    internal func didSave() { }

    @objc private func didTapOnSaveBtn() {
        garanteeMainThread {
            self.didSave()
        }
    }

    @objc private func didTapOnCancelBtn() {
        if needUpdateDetails {
            self.updateDelegate?.didSave()
        }
        navigationController?.popViewController(animated: true)
    }

    internal func didRemoveItem() { }

    @objc private func didTapOnRemoveButton() {
        let alert = UIAlertController(
            title: "Remover item?",
            message: "Deseja mesmo remover este item? Esta ação não pode ser desfeita.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        let removeAction = UIAlertAction(title: "Remover", style: .destructive, handler: { _ in
            self.didRemoveItem()
        })
        alert.addAction(cancelAction)
        alert.addAction(removeAction)
        present(alert, animated: true)
    }

    internal func setupConflictingState() { }

    internal func showPendingConflictsAlert() {
        let alert = UIAlertController(
            title: "Conflitos não resolvidos",
            message: "Existem conflitos ainda não resolvidos em alguns campos.",
            preferredStyle: .alert
        )
        let compareAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(compareAction)
        present(alert, animated: true)
    }

    internal func showConflictAlert() {
        let alert = UIAlertController(
            title: "Conflito de versão",
            message: "Alguém salvou uma nova versão desse documento enquanto você fazia suas alterações.",
            preferredStyle: .alert
        )
        let compareAction = UIAlertAction(title: "Comparar versões", style: .default, handler: { _ in
            self.setupConflictingState()
        })
        alert.addAction(compareAction)
        present(alert, animated: true)
    }

    internal func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Salvo com sucesso",
            message: "Suas alterações foram salvas.",
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
