//
//  DispatchBarView.swift
//  CAD
//
//  Created by Samir Chaves on 28/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import MarqueeLabel
import Location
import CoreLocation
import AVFoundation

class DispatchStatusView: UIView {
    let iconView = UIImageView()
    let nameLabel = UIImageView()

    override func didMoveToSuperview() {
        addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

public protocol DispatchBarViewDelegate: class {
    func didOpenMenu()
    func didCloseMenu()
    func didGetError(_ error: NSError)
}

public class DispatchBarView: UIView {
    internal enum DragDirection {
        case horizontal, vertical
    }

    public weak var delegate: DispatchBarViewDelegate?
    internal let parentViewController: UITabBarController

    private let externalSettings = ExternalSettingsService.settings

    internal var currentOccurrenceDetails: OccurrenceDetails?
    internal var currentOccurrenceCoordinates: CLLocationCoordinate2D?
    internal var currentDispatch: Dispatch?
    internal var currentDispatchStatusCode: DispatchStatusCode?

    internal var previousIntermediatePlaceCode: String?
    internal var previousIntermediatePlaceDescription: String?

    internal let bgStorage = CADBackgroundStorageManager.shared

    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    internal var btnDragDirection: DragDirection?
    internal var statusActionDone = false

    internal let topBorder = UIView().enableAutoLayout()
    internal let loadingView = UIActivityIndicatorView().enableAutoLayout()
    internal let occurrenceView = DispatchOccurrenceView().enableAutoLayout()
    internal let errorLabel = UILabel.build(withSize: 14, color: .appRed, alignment: .center)
    internal let releaseDispatchContainer = UIView()
    internal let currentStatusLabel = UILabel.build(withSize: 11, alpha: 0.7, color: .appTitle, alignment: .right)
    internal let releaseDispatchView: UIView = {
        let view = UIView().enableAutoLayout()
        let label = UILabel.build(withSize: 13, color: .appRed, text: "Liberar empenho")
        let arrowImage = UIImage(systemName: "chevron.left")?.withTintColor(.appRed, renderingMode: .alwaysOriginal)
        let arrow = UIImageView(image: arrowImage).enableAutoLayout()
        view.addSubview(label)
        view.addSubview(arrow)
        label.right(to: view.trailingAnchor, -25).centerY(view: view)
        NSLayoutConstraint.activate([
            arrow.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -15),

            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -14),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
        ])
        view.isHidden = true
        view.alpha = 0.7
        return view
    }()
    internal let changeStatusDragViewHeight: CGFloat = 100
    internal let changeStatusLabel: UILabel = {
        let label = UILabel.build(withSize: 13, color: .white, text: "   Deslocamento para local intermediário   ")
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        return label
    }()

    internal let changeStatusBtn = StatusButton()

    internal let changeStatusDragView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        container.layer.cornerRadius = 25
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        container.isHidden = true
        return container.enableAutoLayout()
    }()

    internal let statusBtn = StatusButton()

    @CadServiceInject
    internal var cadService: CadService

    @OccurrenceServiceInject
    internal var occurrenceService: OccurrenceService

    @DispatchServiceInject
    internal var dispatchService: DispatchService

    internal let locationService = LocationService.shared

    internal let cadNotificationManager = CadNotificationManager.shared
    internal let cadLocationNotificationManager = CadLocationBasedNotificationManager.shared

    internal let status: [DispatchStatus] = [
        .arrivedAtIntermediatePlace,
        .movingToIntermediatePlace,
        .arrived,
        .moving,
        .dispatched
    ].compactMap { $0 }

    internal var currentStatus: DispatchStatus? = .dispatched

    public init(parentViewController: UITabBarController) {
        self.parentViewController = parentViewController
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToSuperview() {
        addSubview(changeStatusDragView)
        changeStatusDragView.addSubview(changeStatusLabel)
        changeStatusDragView.addSubview(changeStatusBtn)

        addSubview(topBorder)
        addSubview(occurrenceView)
        addSubview(errorLabel)
        addSubview(statusBtn)
        addSubview(loadingView)
        addSubview(releaseDispatchContainer)
        releaseDispatchContainer.addSubview(releaseDispatchView)

        releaseDispatchView.addSubview(currentStatusLabel)
        currentStatusLabel.width(200)
        NSLayoutConstraint.activate([
            currentStatusLabel.centerYAnchor.constraint(equalTo: releaseDispatchView.centerYAnchor, constant: 10),
            currentStatusLabel.trailingAnchor.constraint(equalTo: releaseDispatchView.trailingAnchor, constant: -25)
        ])

        errorLabel.isHidden = true

        if UserStylePreferences.theme.style == .dark {
            backgroundColor = UIColor.appBackground.darker(by: 0.3)
        } else {
            backgroundColor = UIColor.appBackground.lighter(by: 0.8)
        }

        setupGestures()
        setupLayout()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didUpdateDispatchStatus), name: .cadDispatchDidUpdate, object: nil)
        center.addObserver(self, selector: #selector(didUpdateOccurrence), name: .cadDispatchedOccurrenceDidUpdate, object: nil)
        center.addObserver(self, selector: #selector(shouldUpdateDispatchStatus), name: .cadDispatchShouldUpdate, object: nil)
        center.addObserver(self, selector: #selector(showPreviewModal), name: .cadPreviewDispatchOccurrence, object: nil)
        center.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupLayout() {
        changeStatusLabel.centerY(view: changeStatusBtn).height(26)
        changeStatusLabel.trailingAnchor.constraint(equalTo: changeStatusDragView.leadingAnchor, constant: -15).isActive = true

        topBorder.width(self)
            .height(1.5)
            .left(self, mutiplier: 0)
            .top(to: topAnchor, mutiplier: 0)

        changeStatusDragView.width(50).height(changeStatusDragViewHeight).centerX(view: statusBtn)
        changeStatusDragView.transform = CGAffineTransform(translationX: 0, y: changeStatusDragViewHeight)
        statusBtn.enableAutoLayout().width(65).height(self)

        changeStatusBtn.enableAutoLayout()
            .centerX(view: changeStatusDragView)
            .top(to: changeStatusDragView.topAnchor, mutiplier: 1)
            .width(40).height(40)

        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor),

            occurrenceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            occurrenceView.trailingAnchor.constraint(equalTo: statusBtn.leadingAnchor),
            occurrenceView.topAnchor.constraint(equalTo: topBorder.bottomAnchor),
            occurrenceView.bottomAnchor.constraint(equalTo: bottomAnchor),

            releaseDispatchView.trailingAnchor.constraint(equalTo: statusBtn.leadingAnchor, constant: -20),
            releaseDispatchView.topAnchor.constraint(equalTo: topBorder.bottomAnchor),
            releaseDispatchView.bottomAnchor.constraint(equalTo: bottomAnchor),

            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            errorLabel.topAnchor.constraint(equalTo: topAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            statusBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusBtn.trailingAnchor.constraint(equalTo: trailingAnchor),

            changeStatusDragView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            changeStatusDragView.bottomAnchor.constraint(equalTo: topBorder.topAnchor)
        ])
    }

    private func storeOccurrenceInCache(_ occurrence: OccurrenceDetails) {
        let data = try? JSONEncoder().encode(occurrence)
        let jsonString = data.flatMap { String(data: $0, encoding: .utf8) }
        UserDefaults.standard.set(jsonString, forKey: "cached_dispatched_occurrence")
    }

    public func configure(with occurrence: OccurrenceDetails, dispatch: Dispatch) {
        storeOccurrenceInCache(occurrence)
        currentOccurrenceDetails = occurrence
        cadService.setDispatchedOccurrence(occurrence)
        bgStorage.currentDispatchedOccurrence = OccurrencePushNotification(dispatch: dispatch, occurrenceDetails: occurrence)

        if let latitude = occurrence.address.coordinates?.latitude,
           let longitude = occurrence.address.coordinates?.longitude {
            currentOccurrenceCoordinates = CLLocationCoordinate2D(
                latitude: latitude, longitude: longitude
            )
        }
        currentDispatch = dispatch

        let statusCodeStr = dispatch.status
        if let currentStatusCode = DispatchStatusCode(rawValue: statusCodeStr),
           let currentStatus = DispatchStatus.getStatusBy(code: currentStatusCode) {
            currentDispatchStatusCode = currentStatusCode
            setCurrentStatus(currentStatus)
        }
        self.occurrenceView.configure(with: occurrence, dispatch: dispatch)
        self.topBorder.backgroundColor = occurrence.generalInfo.priority.color
    }

    public func configure(with occurrenceId: UUID, dispatch: Dispatch, statusCode: DispatchStatusCode) {
        currentDispatch = dispatch
        currentDispatchStatusCode = statusCode

        occurrenceView.fadeOut()
        errorLabel.fadeOut()
        loadingView.startAnimating()
        occurrenceService.getOccurrenceById(occurrenceId) { result in
            switch result {
            case .success(let occurrenceDetails):
                self.currentOccurrenceDetails = occurrenceDetails
                if let occurrenceCoordinates = occurrenceDetails.address.coordinates {
                    self.currentOccurrenceCoordinates = CLLocationCoordinate2D(
                        latitude: occurrenceCoordinates.latitude, longitude: occurrenceCoordinates.longitude
                    )
                }
                garanteeMainThread {
                    self.storeOccurrenceInCache(occurrenceDetails)

                    if let currentStatus = DispatchStatus.getStatusBy(code: statusCode) {
                        self.setCurrentStatus(currentStatus)
                    }

                    self.loadingView.stopAnimating()
                    self.occurrenceView.fadeIn()
                    self.errorLabel.fadeOut()
                    self.occurrenceView.configure(with: occurrenceDetails, dispatch: dispatch)
                    self.topBorder.backgroundColor = occurrenceDetails.generalInfo.priority.color
                    self.bgStorage.currentDispatchedOccurrence = OccurrencePushNotification(dispatch: dispatch, occurrenceDetails: occurrenceDetails)
                    self.cadService.setDispatchedOccurrence(occurrenceDetails)
                    NotificationCenter.default.post(name: .cadDidDispatchedOccurrenceLoad, object: nil, userInfo: [
                        "dispatchedOccurrence": occurrenceDetails
                    ])
                }
            case .failure(let error as NSError):
                garanteeMainThread {
                    self.loadingView.stopAnimating()
                    self.delegate?.didGetError(error)
                    self.errorLabel.fadeIn()
                    if error.code == 404 {
                        self.errorLabel.text = "Ocorrência não encontrada. \n Toque para tentar novamente."
                    } else if self.parentViewController.isUnauthorized(error) {
                        self.parentViewController.gotoLogin(error.domain)
                    } else {
                        self.errorLabel.text = "\(error.domain) \n Toque para tentar novamente."
                    }
                }
            }
        }
    }

    func setCurrentStatus(_ status: DispatchStatus) {
        currentStatus = status
        if status.raw.code == .dispatched,
           let userCoordinates = locationService.currentLocation?.coordinate {
            cadLocationNotificationManager.registerForLeaveCircularRegion(
                center: userCoordinates,
                radius: CLLocationDistance(externalSettings.realTime.dispatchInDisplacementRadius)
            )
        }
        if status.raw.code == .moving,
           let occurrenceCoordinates = currentOccurrenceCoordinates {
            cadLocationNotificationManager.registerForEnterInCircularRegion(
                center: occurrenceCoordinates,
                radius: CLLocationDistance(externalSettings.realTime.dispatchArrivalRadius)
            )
        }
        changeStatusLabel.text = "  \(currentStatus?.next?.raw.description ?? "")  "
        changeStatusBtn.setImage(currentStatus?.next?.icon)
        statusBtn.setImage(currentStatus?.icon)
        currentStatusLabel.text = "  Status atual: \(currentStatus?.raw.description ?? "")  "
    }

    @objc private func appBecomeActive() {
        if let currentStatus = currentStatus,
           let bgDispatchStatus = bgStorage.currentDispatchStatus,
           currentStatus.raw.code != bgDispatchStatus.raw.code {
            setCurrentStatus(bgDispatchStatus)
        } else if let currentDispatchedOccurrence = self.bgStorage.currentDispatchedOccurrence {
            configure(
                with: currentDispatchedOccurrence.occurrenceDetails,
                dispatch: currentDispatchedOccurrence.dispatch
            )
        }
    }
}

extension DispatchBarView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UILongPressGestureRecognizer {
            return true
        }
        return false
    }
}

extension DispatchBarView: IntermediatePlacePickerDelegate {
    func didUpdateStatus(to newStatus: DispatchStatus, withIntermediatePlace intermediatePlace: String?, description: String?) {
        if newStatus.raw.code == .movingToIntermediatePlace {
            previousIntermediatePlaceCode = intermediatePlace
            previousIntermediatePlaceDescription = description
        } else {
            previousIntermediatePlaceCode = nil
            previousIntermediatePlaceDescription = nil
        }
        setCurrentStatus(newStatus)
    }
}
