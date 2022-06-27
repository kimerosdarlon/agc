//
//  OccurrenceCollapsablePropertyView.swift
//  CAD
//
//  Created by Samir Chaves on 16/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

protocol OccurrenceHistoryPropertyViewDelegate: class {
    func didClickOnShowMore()
}

class OccurrenceHistoryPropertyView: UIView {

    weak var delegate: OccurrenceHistoryPropertyViewDelegate?
    private var isCollapsed = true
    private var occurrence: OccurrenceDetails!
    private var maxHeight: CGFloat?
    private var originalFrame: CGRect?
    private var collapseHeightConstraint: NSLayoutConstraint?
    private let iconImage: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.enableAutoLayout().width(16).height(16)
        return imageView
    }()

    private let showMoreBtn: AGCRoundedButton = {
        let button = AGCRoundedButton(text: "Mostrar mais", loadingText: "").width(110).height(35).enableAutoLayout()
        button.addTarget(self, action: #selector(showRemainingHistory), for: UIControl.Event.touchUpInside)
        return button
    }()
    private let titleLabel = UILabel.build(withSize: 12, weight: .bold)
    private var arrowIcon = UIImageView(image: UIImage(systemName: "chevron.down")?.withTintColor(.white, renderingMode: .alwaysOriginal) ).enableAutoLayout()

    private let collapsableView = UIView().enableAutoLayout()
    private let headerView = UIView().enableAutoLayout()

    private let contentView: UIView = {
        let view = UIView()
        view.enableAutoLayout()
        return view
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(title: String, occurrence: OccurrenceDetails, iconName: String, iconColor: UIColor? = nil ) {
        super.init(frame: .zero)
        iconImage.image = UIImage(named: iconName)?.withTintColor(iconColor ?? .appTitle, renderingMode: .alwaysOriginal)
        titleLabel.text = title
        self.occurrence = occurrence

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.showRemainingHistory(sender:)))
        showMoreBtn.addGestureRecognizer(gesture)
    }

    private func fillEmpty(_ text: String?) -> String {
        text?.fillEmpty() ?? String.emptyProperty
    }

    @objc private func showRemainingHistory(sender: UITapGestureRecognizer) {
        delegate?.didClickOnShowMore()
    }

    @objc private func toggleCollapse(sender: UITapGestureRecognizer) {
        if originalFrame == nil {
            originalFrame = contentView.frame
        }
        UIView.animate(withDuration: 0.3) { [unowned self] in
            layoutIfNeeded()
        }

        isCollapsed = !isCollapsed
        print(isCollapsed)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        enableAutoLayout()

        addSubview(headerView)
        headerView.addSubview(iconImage)
        headerView.addSubview(arrowIcon)
        headerView.addSubview(titleLabel)
        addSubview(contentView)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleCollapse(sender:)))
        headerView.addGestureRecognizer(gesture)
        collapsableView.backgroundColor = UIColor.appTitle.withAlphaComponent(0.2)

        let listBuilder = ListBasedDetailBuilder(into: collapsableView, boldFontSize: 12, regularFontSize: 14, spacing: 0.5, widthMultiplier: 1)
        contentView.addSubview(collapsableView)
        contentView.addSubview(showMoreBtn)

        let historyBlocks = occurrence.history[..<min(3, occurrence.history.count)].map { historyItem -> DetailsBlock in
            let timeZone = occurrence.generalInfo.occurrenceRegisteredAt.timeZone
            var dateTime: String?
            dateTime = historyItem.dateTime
                .toDate(format: "yyyy-MM-dd'T'HH-mm-ss")?
                .fromUTCTo(timeZone)
                .format(to: "dd/MM/yyyy HH:mm:ss")
            dateTime = dateTime.map { s in "\(s) \(timeZone)" }
            return DetailsBlock(
                group: DetailsGroup(items: [
                    [
                        (title: "Operador", detail: fillEmpty(historyItem.owner?.name)),
                        (title: "Data", detail: fillEmpty(dateTime))
                    ],
                    [(title: "Tipo", detail: fillEmpty(historyItem.eventType))],
                    [(title: "Texto", detail: fillEmpty(historyItem.eventDescription))]
                ]),
                identifier: historyItem.dateTime + historyItem.eventType
            )
        }

        if occurrence.history.count < 4 {
            showMoreBtn.isHidden = true
        }

        listBuilder.buildDetailsBlocks(historyBlocks)

        collapseHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 20),

            iconImage.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            iconImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 25),
            contentView.bottomAnchor.constraint(equalTo: showMoreBtn.bottomAnchor, constant: 10),

            titleLabel.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            collapsableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collapsableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collapsableView.trailingAnchor.constraint(equalTo: trailingAnchor),

            showMoreBtn.topAnchor.constraint(equalTo: collapsableView.bottomAnchor, constant: 10),
            showMoreBtn.centerXAnchor.constraint(equalTo: collapsableView.centerXAnchor),

            topAnchor.constraint(equalTo: contentView.topAnchor, constant: -12),
            bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            arrowIcon.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
            arrowIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            arrowIcon.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10)
        ])
        listBuilder.setupLayout()
    }
}
