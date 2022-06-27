//
//  OverMapNavigationController.swift
//  CAD
//
//  Created by Samir Chaves on 28/04/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon

class OverMapNavigation: UntouchableView {

    enum OverMapViews {
        case home, radiusDrawing
    }

    private var mapView: RealTimeMapView
    private var homeView: MapHomeView
    private var radiusDrawingView: RadiusDrawingView
    private var parentViewController: UIViewController
    private var currentMap: OverMapViews = .home

    init(mapView: RealTimeMapView,
         occurrencesDataSource: RecentOccurrencesDataSource,
         teamsManager: TeamMembersManager,
         parentViewController: UIViewController) {
        self.mapView = mapView
        self.parentViewController = parentViewController
        self.homeView = MapHomeView(mapView: mapView, occurrencesDataSource: occurrencesDataSource, teamsManager: teamsManager, parentViewController: parentViewController)
        self.radiusDrawingView = RadiusDrawingView(mapView: mapView, dataSource: occurrencesDataSource, parentViewController: parentViewController)
        super.init(frame: .zero)
        self.homeView.navigation = self
        self.radiusDrawingView.navigation = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    private func hideView(_ view: UIView, completion: (() -> Void)? = nil) {
        if !view.isHidden {
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0
                view.transform = CGAffineTransform.identity.translatedBy(x: 50, y: 0)
            }, completion: { _ in
                view.isHidden = true
                completion?()
            })
        }
    }

    private func showView(_ view: UIView, completion: (() -> Void)? = nil) {
        if view.isHidden {
            view.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 1
                view.transform = CGAffineTransform.identity
            }, completion: { _ in
                completion?()
            })
        }
    }

    func goToHome() {
        hideView(radiusDrawingView) {
            self.showView(self.homeView)
        }
    }

    func goToRadiusDrawing() {
        radiusDrawingView.setInitialCircle(initialRadius: mapView.getCircleRadius(), initialLocation: mapView.getCirclePosition())
        hideView(homeView) {
            self.showView(self.radiusDrawingView)
        }
    }

    override func didMoveToSuperview() {
        addSubview(homeView)
        homeView.enableAutoLayout()
        homeView.fillSuperView(regardSafeArea: true)

        addSubview(radiusDrawingView)
        radiusDrawingView.enableAutoLayout()
        radiusDrawingView.fillSuperView(regardSafeArea: true)
        radiusDrawingView.alpha = 0
        radiusDrawingView.isHidden = true
    }
}
