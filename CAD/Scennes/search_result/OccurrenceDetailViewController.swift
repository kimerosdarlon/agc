//
//  OccurrenceDetailViewController.swift
//  CAD
//
//  Created by Samir Chaves on 10/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import UIKit
import ViewPager_Swift

public class OccurrenceDetailViewController: UIViewController {
    private var pagerView: OccurrencePagerViewController
    private let alertHeader: OccurrenceAlertHeader
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    private var occurrence: OccurrenceDetails
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.backgroundColor = UIColor.appBackground.withAlphaComponent(0.6)
        indicator.style = .large
        return indicator.enableAutoLayout()
    }()

    @CadServiceInject
    private var cadService: CadService

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    public init(occurrence: OccurrenceDetails) {
        self.occurrence = occurrence
        self.pagerView = OccurrencePagerViewController(occurrence: occurrence)
        self.alertHeader = OccurrenceAlertHeader(dateTime: occurrence.generalInfo.generalAlertClassificationDateTime?.toDate(format: "yyyy-MM-dd'T'HH:mm:ss"))

        super.init(nibName: nil, bundle: nil)

        self.pagerView.updateDelegate = self

        self.title = occurrence.generalInfo.protocol

        if !occurrence.generalInfo.generalAlert {
            alertHeader.height(0)
            alertHeader.isHidden = true
        }

        modalPresentationStyle = .custom
        transitionDelegate = DefaultModalPresentationManager(heightFactor: 0.9, position: .center)
        transitioningDelegate = transitionDelegate
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        GalleryView.cleanCache()
        
        pagerView.view.enableAutoLayout()
        view.addSubview(pagerView.view)
        view.addSubview(alertHeader)
        view.bringSubviewToFront(pagerView.view)
        addChild(pagerView)
        pagerView.didMove(toParent: self)
        view.addSubview(loadingIndicator)
        loadingIndicator.fillSuperView()

        alertHeader.configure()
        setupLayout()

        if let backIcon = UIImage(systemName: "chevron.left"), isModal {
            let closeBtn = UIBarButtonItem(image: backIcon, style: .plain, target: self, action: #selector(back))
            closeBtn.tintColor = .appTitle
            navigationItem.leftBarButtonItem = closeBtn
        }

        if let downloadIcon = UIImage(systemName: "square.and.arrow.down") {
            let downloadBtn = UIBarButtonItem(image: downloadIcon, style: .plain, target: self, action: #selector(downloadOccurrence))
            downloadBtn.tintColor = .appTitle
            navigationItem.rightBarButtonItem = downloadBtn
        }
    }

    @objc private func back() {
        dismiss(animated: true)
    }

    @objc private func downloadOccurrence() {
        let downloadModal = OccurrenceDownloadConfirmModal(occurrenceId: occurrence.occurrenceId, fileName: occurrence.generalInfo.protocol)
        downloadModal.delegate = self
        present(downloadModal, animated: true)
    }

    private func startLoading() {
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
    }

    private func stopLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }

    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            alertHeader.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            alertHeader.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            alertHeader.topAnchor.constraint(equalTo: safeArea.topAnchor),
            pagerView.view.topAnchor.constraint(equalTo: alertHeader.bottomAnchor),
            pagerView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            pagerView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: pagerView.view.bottomAnchor, multiplier: 1)
        ])
    }

    public func refreshOccurrence() {
        startLoading()
        occurrenceService.getOccurrenceById(occurrence.occurrenceId) { result in
            garanteeMainThread {
                self.stopLoading()
                switch result {
                case .success(let occurrence):
                    self.pagerView.view.removeFromSuperview()
                    self.pagerView.removeFromParent()
                    self.pagerView = OccurrencePagerViewController(occurrence: occurrence)
                    self.pagerView.view.enableAutoLayout()
                    self.pagerView.updateDelegate = self
                    self.view.addSubview(self.pagerView.view)
                    self.view.bringSubviewToFront(self.loadingIndicator)
                    self.addChild(self.pagerView)
                    self.pagerView.didMove(toParent: self)
                    self.setupLayout()
                case .failure(let error as NSError):
                    Toast.present(in: self, title: "Não foi possível recarregar os dados", message: error.domain)
                }
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .appBackground
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GalleryView.cleanCache()
    }
}

extension OccurrenceDetailViewController: OccurrenceDataUpdateDelegate {
    func didSave() {
        GalleryView.cleanCache()
        cadService.refreshResource(completion: { _ in })
        refreshOccurrence()
    }
}

extension OccurrenceDetailViewController: OccurrenceDownloadConfirmDelegate {
    func didDownloadPdf(_ fileUrl: URL) {
        garanteeMainThread {
            let pdfScreen = PDFViewController(pdfURL: fileUrl)
            self.navigationController?.pushViewController(pdfScreen, animated: true)
        }
    }
}
