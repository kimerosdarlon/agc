//
//  ObjectDetailsViewController.swift
//  CAD
//
//  Created by Samir Chaves on 22/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class ObjectDetailsViewController: UIViewController {
    weak var updateDelegate: OccurrenceDataUpdateDelegate?

    @CadServiceInject
    internal var cadService: CadService

    internal var detail: OccurrenceDetails!
    internal let dateFormatter = DateFormatter()
    internal let datetimeFormatter = DateFormatter()
    internal var canEdit = false
    private let emptyFeedback: String
    private var detailsContainer: ListBasedDetailTableView<ObjectDetailsCell>!

    private let addButton: UIButton = {
        let size: CGFloat = 48
        let image = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.layer.cornerRadius = size / 2
        btn.backgroundColor = .appBlue
        btn.isUserInteractionEnabled = true
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = .init(width: 0, height: 7)
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowRadius = 3
        btn.addTarget(self, action: #selector(didTapOnAddButton), for: .touchUpInside)
        return btn.enableAutoLayout().width(size).height(size)
    }()

    init(with occurrence: OccurrenceDetails, emptyFeedback: String) {
        self.emptyFeedback = emptyFeedback
        super.init(nibName: nil, bundle: nil)
        detail = occurrence

        self.detailsContainer = ListBasedDetailTableView<ObjectDetailsCell>(
            padding: .init(top: 15, left: 15, bottom: 0, right: 15),
            parentViewController: self
        ).enableAutoLayout()

        if let dispatchedOccurrenceId = cadService.getDispatchedOccurrence()?.occurrenceId,
           dispatchedOccurrenceId == occurrence.occurrenceId {
            canEdit = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func buildEditButton() -> UIButton {
        let size: CGFloat = 32
        let image = UIImage(named: "pencil")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        btn.backgroundColor = .clear
        btn.isUserInteractionEnabled = true
        return btn.enableAutoLayout().width(size).height(size)
    }

    internal func fillBlankField(_ value: String?) -> String {
        value == nil ? String.emptyProperty : value!.fillEmpty()
    }

    internal func getDetailsBlocks() -> [DetailsBlock] {
        return [DetailsBlock(groups: [], identifier: "")]
    }

    internal func isEmpty() -> Bool {
        return true
    }

    override func viewDidLoad() {
        view.addSubview(detailsContainer)

        if canEdit {
            view.addSubview(addButton)
            NSLayoutConstraint.activate([
                addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
                addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
            ])
        }

        detailsContainer.delaysContentTouches = true
        detailsContainer.canCancelContentTouches = false

        if isEmpty() {
            let notFoundLabel = UILabel.build(withSize: 14, alpha: 0.8, color: .appTitle, alignment: .center, text: emptyFeedback).enableAutoLayout()
            view.addSubview(notFoundLabel)
            notFoundLabel.width(view).height(50).centerX().top(view, mutiplier: 1)
        }

        detailsContainer.height(400)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            detailsContainer.topAnchor.constraint(equalTo: safeArea.topAnchor),
            detailsContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            detailsContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: detailsContainer.bottomAnchor, multiplier: 1)
        ])

        detailsContainer.apply(blocks: getDetailsBlocks())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserStylePreferences.theme.style == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .systemGray5
        }
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    func didAddObject() { }

    @objc private func didTapOnAddButton() {
        didAddObject()
    }
}
