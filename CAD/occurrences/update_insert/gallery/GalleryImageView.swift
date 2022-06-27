//
//  GalleryImageView.swift
//  CAD
//
//  Created by Samir Chaves on 17/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

protocol GalleryImageDelegate: class {
    func didRemoveAnImage(_ image: GalleryImage)
}

class GalleryImageView: UICollectionViewCell {
    static let identifier = String(describing: GalleryImageView.self)

    weak var delegate: GalleryImageDelegate?

    @EntityFilesServiceInject
    private var entityFilesService: EntityFilesService

    private let imageView = UIImageView(frame: .zero).enableAutoLayout()
    private let imageContainer = UIView().enableAutoLayout()

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    private var readOnly: Bool = false

    private let uploadOverlay: UIView = {
        let overlay = UIView().enableAutoLayout()
        overlay.layer.cornerRadius = 5
        overlay.backgroundColor = UIColor.appBackground.withAlphaComponent(0.5)
        let uploadIcon = UIImageView(
            image: UIImage(systemName: "icloud.and.arrow.up.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        ).enableAutoLayout()
        overlay.addSubview(uploadIcon)
        uploadIcon.centerX().centerY()
        overlay.isHidden = true
        return overlay
    }()
    private let loadingOverlay: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView().enableAutoLayout()
        indicator.backgroundColor = UIColor.appBackground.withAlphaComponent(0.7)
        return indicator
    }()

    private let removeBtn: UIButton = {
        let size: CGFloat = 29
        let image = UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = .init(top: 4, left: 4, bottom: 8, right: 8)
        btn.layer.cornerRadius = size / 2
        btn.backgroundColor = .appBlue
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentMode = .center
        btn.isUserInteractionEnabled = true
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = .init(width: 0, height: 7)
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowRadius = 3
        btn.isHidden = true
        return btn.enableAutoLayout().width(size).height(size)
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        contentView.isUserInteractionEnabled = false
        backgroundColor = .appBackground    

        addSubview(imageContainer)
        imageContainer.addSubview(imageView)
        addSubview(removeBtn)
        imageView.contentMode = .scaleAspectFill
        imageContainer.fillSuperView()
        imageView.fillSuperView()
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = 5
        bringSubviewToFront(removeBtn)
        addSubview(uploadOverlay)
        uploadOverlay.fillSuperView()
        addSubview(loadingOverlay)
        loadingOverlay.fillSuperView()

        NSLayoutConstraint.activate([
            removeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            removeBtn.topAnchor.constraint(equalTo: topAnchor, constant: -5)
        ])
    }

    func setErrorState() {
        loadingOverlay.stopAnimating()
        uploadOverlay.isHidden = false
        loadingOverlay.isHidden = true
        removeBtn.isHidden = true
    }

    func setUploadingState() {
        loadingOverlay.startAnimating()
        loadingOverlay.isHidden = false
        uploadOverlay.isHidden = true
        removeBtn.isHidden = true
    }

    func setDownloadingState() {
        loadingOverlay.startAnimating()
        loadingOverlay.isHidden = false
        uploadOverlay.isHidden = true
        removeBtn.isHidden = true
    }

    func setReadyState() {
        loadingOverlay.stopAnimating()
        uploadOverlay.isHidden = true
        loadingOverlay.isHidden = true
        if !readOnly {
            removeBtn.isHidden = false
        }
    }

    func configure(with galleryImage: GalleryImage, readOnly: Bool) {
        self.readOnly = readOnly
        if !readOnly {
            removeBtn.addAction {
                self.delegate?.didRemoveAnImage(galleryImage)
            }
        } else {
            removeBtn.isHidden = true
        }

        self.image = galleryImage.image

        switch galleryImage.state {
        case .downloading:
            setDownloadingState()
        case .uploading:
            setUploadingState()
        case .downloadError:
            setErrorState()
        case .uploadError:
            setErrorState()
        case .ready:
            setReadyState()
        }
    }
}
