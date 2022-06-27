//
//  MediaPickerTypeViewController.swift
//  CAD
//
//  Created by Samir Chaves on 17/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

enum MediaPickerType { case camera, gallery }

protocol MediaPickerTypeDelegate: class {
    func didSelectAType(_ type: MediaPickerType)
}

class MediaTypePickerViewController: UIViewController {
    weak var delegate: MediaPickerTypeDelegate?

    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    private var imagePicker = UIImagePickerController()

    private let titleLabel = UILabel.build(withSize: 17, color: .appTitle, alignment: .center, text: "Selecione uma das opções abaixo")

    private func buildPickerOption(label: String, icon: UIImage?, tapGesture: UITapGestureRecognizer) -> UIView {
        let container = UIView()
        let squareView = UIView().enableAutoLayout()
        squareView.backgroundColor = .appBackgroundCell
        squareView.layer.cornerRadius = 7
        squareView.clipsToBounds = true
        squareView.addGestureRecognizer(tapGesture)
        container.addSubview(squareView)
        squareView
            .centerX(view: container)
            .top(to: container.topAnchor, mutiplier: 0)
            .width(130).height(130)

        let iconView = UIImageView(image: icon).enableAutoLayout()
        squareView.addSubview(iconView)
        iconView
            .width(30).height(25)
            .centerX(view: squareView).centerY(view: squareView)

        let label = UILabel.build(withSize: 14, color: .appTitle, text: label)
        container.addSubview(label)
        label
            .centerX(view: squareView)
            .top(to: squareView.bottomAnchor, mutiplier: 2)
            .bottom(to: container.bottomAnchor, 0)
        return container.enableAutoLayout()
    }

    private var galleryOption: UIView!
    private var cameraOption: UIView!

    private let optionsContainer = UIView().enableAutoLayout()

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom

        let galleryTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnGalleryOption))
        galleryOption = buildPickerOption(
            label: "Galeria",
            icon: UIImage(systemName: "photo.on.rectangle")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal),
            tapGesture: galleryTapGesture
        )

        let cameraTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnCameraOption))
        cameraOption = buildPickerOption(
            label: "Câmera",
            icon: UIImage(systemName: "camera.fill")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal),
            tapGesture: cameraTapGesture
        )

        transitionDelegate = PresentationManager(padding: .zero, heightFactor: 0.3)
        transitioningDelegate = transitionDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func openPicker(for type: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return }

        self.imagePicker.sourceType = type
        self.present(self.imagePicker, animated: true)
    }

    @objc func didTapOnGalleryOption() {
        dismiss(animated: true) {
            self.delegate?.didSelectAType(.gallery)
        }
    }

    @objc func didTapOnCameraOption() {
        dismiss(animated: true) {
            self.delegate?.didSelectAType(.camera)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground
        view.addSubview(titleLabel)
        titleLabel.height(35)
        view.addSubview(optionsContainer)
        optionsContainer.addSubview(galleryOption)
        optionsContainer.addSubview(cameraOption)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            optionsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            optionsContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            optionsContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            optionsContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10),

            galleryOption.centerYAnchor.constraint(equalTo: optionsContainer.centerYAnchor),
            galleryOption.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            galleryOption.trailingAnchor.constraint(equalTo: optionsContainer.centerXAnchor),
            cameraOption.centerYAnchor.constraint(equalTo: optionsContainer.centerYAnchor),
            cameraOption.leadingAnchor.constraint(equalTo: optionsContainer.centerXAnchor),
            cameraOption.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor)
        ])
    }
}
