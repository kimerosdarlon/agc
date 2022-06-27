//
//  RecentOccurrenceViewController.swift
//  CAD
//
//  Created by Samir Chaves on 12/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import Location
import AgenteDeCampoCommon
import CoreLocation

protocol RecentOccurrenceDelegate: class {
    func didBack()
    func didTapInDetailsButton(_ occurrenceId: UUID, completion: @escaping () -> Void)
}

class RecentOccurrenceViewController: UIViewController {
    weak var delegate: RecentOccurrenceDelegate?
    private var details: SimpleOccurrence
    private let locationService = LocationService.shared
    private let showDispatches: Bool

    init(occurrence: SimpleOccurrence, showDispatches: Bool = true) {
        self.details = occurrence
        self.showDispatches = showDispatches
        operatingRegionsTags = TagGroupView(tags: [occurrence.operatingRegion.name], backGroundCell: .clear, containerBackground: .clear, tagBordered: true)
        super.init(nibName: nil, bundle: nil)
        title = occurrence.protocol
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let detailsButton: UIButton = {
        let image = UIImage(systemName: "doc.text.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle(" Detalhes", for: .normal)
        btn.setImage(image, for: .normal)
        btn.imageView?.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .appBlue
        btn.addTarget(self, action: #selector(goToDetails), for: .touchUpInside)
        return btn
    }()

    private let routeButton: UIButton = {
        let image = UIImage(named: "routing")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .system).enableAutoLayout()
        btn.setTitle("Rota", for: .normal)
        btn.setImage(image, for: .normal)
        if let imageView = btn.imageView,
           let titleLabel = btn.titleLabel {
            imageView.enableAutoLayout().width(25).height(25).centerY(view: btn)
            imageView.centerXAnchor.constraint(equalTo: btn.centerXAnchor, constant: -20).isActive = true
            titleLabel.enableAutoLayout().centerY(view: btn)
            titleLabel.transform = CGAffineTransform(translationX: 8, y: 0)
        }
        btn.setTitleColor(.appCellLabel, for: .normal)
        btn.backgroundColor = .appBackgroundCell
        btn.addTarget(self, action: #selector(didTapOnRouteBtn), for: .touchUpInside)
        return btn
    }()

    private let backButton: UIButton = {
        let image = UIImage(systemName: "xmark")?.withTintColor(UIColor.appTitle.withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .custom)
        btn.frame = .init(x: 5, y: 5, width: 40, height: 40)
        btn.layer.cornerRadius = btn.bounds.height * 0.5
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 13)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(backPage), for: .touchUpInside)
        return btn.enableAutoLayout().height(40).width(40)
    }()

    @objc func didTapOnRouteBtn() {
        let address = details.address
        let formattedAddress = address.getFormattedAddress()
        let coordinate = CLLocationCoordinate2D(
            latitude: details.address.coordinates?.latitude ?? 0,
            longitude: details.address.coordinates?.longitude ?? 0
        )
        self.openMaps(from: locationService.currentLocation?.coordinate, to: coordinate, withTitle: formattedAddress)
    }

    private var situationLabel = OccurrenceSituationLabel()

    private let propertiesList: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.enableAutoLayout()
        return stack
    }()

    @objc private func goToDetails() {
        detailsButton.alpha = 0.8
        detailsButton.setTitle(" Carregando...", for: .normal)
        delegate?.didTapInDetailsButton(details.id) {
            self.detailsButton.alpha = 1
            self.detailsButton.setTitle(" Detalhes", for: .normal)
        }
    }

    private var operatingRegionsTags: TagGroupView

    private var placeView: UIStackView = {
        let placeView = UIStackView().enableAutoLayout()
        placeView.axis = .vertical
        placeView.distribution = .fillProportionally
        placeView.alignment = .fill
        placeView.spacing = 10
        return placeView
    }()

    @objc func backPage() {
        navigationController?.popViewController(animated: true)
        delegate?.didBack()
    }

    private func fillBlankField(_ value: String?) -> String {
        value == nil ? String.emptyProperty : value!.fillEmpty()
    }

    private let container: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.enableAutoLayout()
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .appBackground
        situationLabel = situationLabel.withSituation(details.situation)

        let address = details.address
        let formattedAddress = address.getFormattedAddress(withCoordinates: true)
        placeView.addArrangedSubviewList(
            views: UILabel.build(withSize: 16, color: UIColor.appTitle, text: formattedAddress), operatingRegionsTags
        )
        operatingRegionsTags.enableAutoLayout().height(40).width(placeView)

        var properties: [OccurrencePropertyView] = [
            OccurrenceTextPropertyView(title: "Protocolo",
                                       description: details.protocol,
                                       iconName: "file",
                                       extra: OccurrencePriorityLabel().withPriority(details.priority))
        ]
        if self.showDispatches {
            properties.append(
                OccurrenceTextPropertyView(title: "Equipes",
                                           description: fillBlankField(details.allocatedTeams.map { $0.name }.joined(separator: ", ")),
                                           iconName: "people")
            )
        }
        properties.append(contentsOf: [
            OccurrenceTextPropertyView(title: "Registro do Atendimento em",
                                       description: details.serviceRegisteredAt.format(),
                                       iconName: "calendar"),
            OccurrenceTextPropertyView(title: "Despachante",
                                       description: fillBlankField(details.operator?.name),
                                       iconName: "operator"),
            OccurrenceTagsPropertyView(title: "Naturezas",
                                       tags: details.natures.map { $0.name },
                                       iconName: "handcuffs")
        ])

        propertiesList.addArrangedSubviewList(views: properties)

        view.addSubview(backButton)
        view.addSubview(situationLabel)
        view.addSubview(container)
        view.addSubview(routeButton)
        view.addSubview(detailsButton)
        container.addSubview(placeView)
        container.addSubview(propertiesList)

        setupLayout()
    }

    func setupLayout() {
        let padding: CGFloat = 10

        routeButton.height(45)
        detailsButton.height(45)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),

            situationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding + 2),
            situationLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            container.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: padding),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            placeView.topAnchor.constraint(equalTo: container.topAnchor),
            placeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            placeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),

            propertiesList.topAnchor.constraint(equalTo: placeView.bottomAnchor, constant: padding),
            propertiesList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            propertiesList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            view.bottomAnchor.constraint(equalTo: detailsButton.bottomAnchor),

            routeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            routeButton.bottomAnchor.constraint(equalTo: detailsButton.bottomAnchor),

            detailsButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            detailsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            container.bottomAnchor.constraint(equalTo: propertiesList.bottomAnchor),
            detailsButton.topAnchor.constraint(equalToSystemSpacingBelow: container.bottomAnchor, multiplier: 1)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}
