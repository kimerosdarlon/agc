//
//  MapHomeViewControlelr.swift
//  CAD
//
//  Created by Samir Chaves on 28/04/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class MapHomeView: UntouchableView {
    weak var navigation: OverMapNavigation?
    private var mapView: RealTimeMapView!
    private var parentViewController: UIViewController
    private let dataSource: RecentOccurrencesDataSource
    private let radiusPopover = RealtimeRadiusPopover().enableAutoLayout()
    private let realtimeFilter: RealTimeFilterViewController

    private let searchInput = TextFieldComponent(placeholder: "Busque por ocorrências e equipes", label: "").enableAutoLayout()

    private let filtersCountLabel: UILabel = {
        let label = UILabel.build(withSize: 11, weight: .bold, color: .appBlue, alignment: .center)
        label.backgroundColor = .white
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()

    @CadServiceInject
    private var cadService: CadService

    private let filtersButton: UIButton = {
        let size: CGFloat = 48
        let image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.layer.cornerRadius = size / 2
        btn.backgroundColor = .appBlue
        btn.isUserInteractionEnabled = true
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = .init(width: 0, height: 7)
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowRadius = 3
        btn.addTarget(self, action: #selector(didTapOnFilterButton), for: .touchUpInside)
        return btn.enableAutoLayout().width(size).height(size)
    }()

    private let userPositionButton: UIButton = {
        let size: CGFloat = 42
        let image = UIImage(named: "blueTarget")
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        btn.layer.cornerRadius = size / 2
        btn.backgroundColor = .white
        btn.isUserInteractionEnabled = true
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = .init(width: 0, height: 7)
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowRadius = 3
        btn.addTarget(self, action: #selector(didTapOnUserPositionButton), for: .touchUpInside)
        return btn.enableAutoLayout().width(size).height(size)
    }()

    private let radiusButton: UIButton = {
        let size: CGFloat = 42
        let image = UIImage(named: "radiusEdit")
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        btn.layer.cornerRadius = size / 2
        btn.backgroundColor = .white
        btn.isUserInteractionEnabled = true
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = .init(width: 0, height: 7)
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowRadius = 3
        btn.addTarget(self, action: #selector(didTapOnRadiusButton), for: .touchUpInside)
        return btn.enableAutoLayout().width(size).height(size)
    }()

    private let generalAlertBalloon = GeneralAlertBalloon()

    @objc private func didTapOnRadiusButton() {
        radiusPopover.toggleVisibility()
    }

    @objc private func didTapOnFilterButton() {
        parentViewController.present(realtimeFilter, animated: true)
    }

    @objc private func didTapOnUserPositionButton() {
        mapView.centerMap()
    }

    init(mapView: RealTimeMapView,
         occurrencesDataSource: RecentOccurrencesDataSource,
         teamsManager: TeamMembersManager,
         parentViewController: UIViewController) {
        self.mapView = mapView
        self.parentViewController = parentViewController
        self.dataSource = occurrencesDataSource
        self.realtimeFilter = RealTimeFilterViewController(occurrencesDataSource: occurrencesDataSource, teamsManager: teamsManager)
        super.init(frame: .zero)
        radiusPopover.delegate = self
        occurrencesDataSource.addDelegate(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        userPositionButton.removeFromSuperview()
        addSubview(userPositionButton)

        if !cadService.realtimeOccurrencesAllowed() && !cadService.realtimeExternalTeamsAllowed() {
            NSLayoutConstraint.activate([
                userPositionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                userPositionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
            ])
        } else if cadService.realtimeOccurrencesAllowed() {
            radiusPopover.removeFromSuperview()
            radiusButton.removeFromSuperview()
            filtersButton.removeFromSuperview()
            filtersCountLabel.removeFromSuperview()

            addSubview(searchInput)
            addSubview(generalAlertBalloon.enableAutoLayout())
            addSubview(radiusButton)
            addSubview(filtersButton)
            addSubview(filtersCountLabel)
            addSubview(radiusPopover)

            filtersCountLabel.width(20).height(20)

            radiusPopover.width(330)
            searchInput.textField.layer.cornerRadius = 20
            searchInput.alpha = 0.7
            searchInput.textField.delegate = self
            searchInput.textField.addLeftIcon(
                iconName: "magnifyingglass",
                color: UIColor.appTitle.withAlphaComponent(0.7),
                size: .init(width: 23, height: 20),
                frame: .init(x: 10, y: -10, width: 50, height: 30),
                position: .init(x: 12, y: 5)
            )

            filtersCountLabel.width(20).height(20)

            NSLayoutConstraint.activate([
                generalAlertBalloon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                generalAlertBalloon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),

                filtersButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                filtersButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),

                filtersCountLabel.trailingAnchor.constraint(equalTo: filtersButton.trailingAnchor, constant: 3),
                filtersCountLabel.topAnchor.constraint(equalTo: filtersButton.topAnchor, constant: -3),

                searchInput.centerXAnchor.constraint(equalTo: centerXAnchor),
                searchInput.topAnchor.constraint(equalTo: topAnchor),
                searchInput.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                searchInput.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

                radiusButton.centerXAnchor.constraint(equalTo: filtersButton.centerXAnchor),
                radiusButton.topAnchor.constraint(equalTo: searchInput.bottomAnchor, constant: 20),

                radiusPopover.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                radiusPopover.topAnchor.constraint(equalTo: radiusButton.bottomAnchor, constant: 10),

                userPositionButton.centerXAnchor.constraint(equalTo: filtersButton.centerXAnchor),
                userPositionButton.bottomAnchor.constraint(equalTo: filtersButton.topAnchor, constant: -15)
            ])
        } else {
            filtersButton.removeFromSuperview()
            filtersCountLabel.removeFromSuperview()
            addSubview(filtersButton)
            addSubview(filtersCountLabel)

            filtersCountLabel.width(20).height(20)
            NSLayoutConstraint.activate([
                filtersButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                filtersButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),

                filtersCountLabel.trailingAnchor.constraint(equalTo: filtersButton.trailingAnchor, constant: 3),
                filtersCountLabel.topAnchor.constraint(equalTo: filtersButton.topAnchor, constant: -3),

                userPositionButton.centerXAnchor.constraint(equalTo: filtersButton.centerXAnchor),
                userPositionButton.bottomAnchor.constraint(equalTo: filtersButton.topAnchor, constant: -15)
            ])
        }
    }
}

extension MapHomeView: RealtimeRadiusPopoverDelegate, RecentOccurrencesDataSourceDelegate {
    func didChangeRadius(_ radius: CGFloat) {
        mapView.beginEditingRadius()
        mapView.updateCircle(radius: radius)
        mapView.endEditingRadius()
        dataSource.fetchRecentOccurrences(location: mapView.getCirclePosition(), radius: radius) { error in
            if let error = error as NSError?, self.parentViewController.isUnauthorized(error) {
                self.parentViewController.gotoLogin(error.domain)
            }
        }
    }

    func didTapOnDrawButton(_ radius: CGFloat) {
        mapView.beginEditingRadius()
        navigation?.goToRadiusDrawing()
    }

    func didUpdateRecentOccurrences(_ occurrences: [SimpleOccurrence]) {
        if dataSource.filtersCount > 0 {
            filtersCountLabel.fadeIn()
        } else {
            filtersCountLabel.fadeOut()
        }

        filtersCountLabel.text = "\(dataSource.filtersCount)"

        let generalAlerts = dataSource.generalAlerts()
        if generalAlerts.count > 0 {
            generalAlertBalloon.fadeIn()
            generalAlertBalloon.setCount(generalAlerts.count)
            if generalAlertBalloon.expanded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.generalAlertBalloon.shrinkGeneralAlertsBalloon()
                }
            }
        } else {
            generalAlertBalloon.fadeOut()
        }
    }
}

extension MapHomeView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let searchViewController = RealTimeSearchViewController()
        if let resultsDelegate = parentViewController as? RTSearchResultsTableDelegate {
            self.resignFirstResponder()
            searchViewController.resultsDelegate = resultsDelegate
            parentViewController.present(searchViewController, animated: true)
        }
    }
}
