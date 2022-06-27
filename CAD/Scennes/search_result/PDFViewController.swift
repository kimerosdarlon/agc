//
//  PDFViewController.swift
//  CAD
//
//  Created by Samir Chaves on 29/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import AgenteDeCampoCommon
import PDFKit
import Combine

public class PDFNavigationController: UINavigationController {
    private var transitionDelegate: UIViewControllerTransitioningDelegate?

    public init(pdfURL: URL) {
        let pdfViewController = PDFViewController(pdfURL: pdfURL)
        super.init(rootViewController: pdfViewController)

        modalPresentationStyle = .custom
        transitionDelegate = DefaultModalPresentationManager(heightFactor: 0.9, position: .center)
        transitioningDelegate = transitionDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PDFViewController: UIViewController {
    private var pdfView: PDFView = PDFView(frame: .zero).enableAutoLayout()
    private let pdfURL: URL

    init(pdfURL: URL) {
        self.pdfURL = pdfURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func share() {
        let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }

    @objc private func back() {
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(pdfView)
        pdfView.fillSuperView(regardSafeArea: false)
        if let pdfDocument = PDFDocument(url: self.pdfURL) {
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            pdfView.displayDirection = .vertical
            pdfView.document = pdfDocument

            guard let shareIcon = UIImage(systemName: "square.and.arrow.up") else { return }
            let shareBtn = UIBarButtonItem(image: shareIcon, style: .plain, target: self, action: #selector(share))
            navigationItem.rightBarButtonItem = shareBtn

            if isModal {
                guard let backIcon = UIImage(systemName: "chevron.left") else { return }
                let backBtn = UIBarButtonItem(image: backIcon, style: .plain, target: self, action: #selector(back))
                navigationItem.leftBarButtonItem = backBtn
            }
        }
    }
}
