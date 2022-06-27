//
//  GalleryView.swift
//  CAD
//
//  Created by Samir Chaves on 17/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import ImageViewer
import AgenteDeCampoCommon

struct GalleryImage: Hashable {
    enum State {
        case downloadError, uploadError, downloading, uploading, ready
    }

    let id: UUID
    let image: UIImage?
    let remoteId: UUID?
    let state: State

    static func == (lhs: GalleryImage, rhs: GalleryImage) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func withState(_ newState: State) -> Self {
        GalleryImage(id: id, image: image, remoteId: remoteId, state: newState)
    }
}

class GalleryView: UICollectionView {
    private static var imagesCache = [UUID: UIImage]()
    private static var galleryCache = [UUID: [UUID]]()

    static func cleanCache() {
        imagesCache = [UUID: UIImage]()
        galleryCache = [UUID: [UUID]]()
    }

    enum Section: Hashable { case main }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, GalleryImage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GalleryImage>

    @EntityFilesServiceInject
    private var entityFilesService: EntityFilesService

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView().enableAutoLayout()
        indicator.backgroundColor = UIColor.appBackground.withAlphaComponent(0.4)
        return indicator
    }()
    private var imagesDataSource: DataSource!
    private var imagePicker = UIImagePickerController()
    private let parentViewController: UIViewController
    private let imageViewerBtn: UIButton = {
        let btn = UIButton(type: .close).enableAutoLayout()
        btn.width(45).height(45)
        return btn
    }()

    private let imagesLayout = LeftAlignedFlowLayout(
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    )

    private var heightConstraint: NSLayoutConstraint?
    private let mockedImage = GalleryImage(id: UUID(), image: nil, remoteId: nil, state: .ready)
    private var selectedImages = [GalleryImage]()
    private let entityId: UUID
    private let readOnly: Bool
    private let picturesPerRow: Int
    private let cacheImages: Bool

    var onFetchImages: (_: [UUID]) -> Void = { _ in }

    init(entityId: UUID, readOnly: Bool = false, picturesPerRow: Int = 4, parentViewController: UIViewController, cacheImages: Bool = false) {
        self.readOnly = readOnly
        self.cacheImages = cacheImages
        self.picturesPerRow = picturesPerRow
        self.entityId = entityId
        self.parentViewController = parentViewController

        if readOnly {
            imagesLayout.scrollDirection = .horizontal
        }

        super.init(frame: .zero, collectionViewLayout: imagesLayout)

        imagesDataSource = makeDataSource()
        dataSource = imagesDataSource
        delegate = self

        register(GalleryImageView.self, forCellWithReuseIdentifier: GalleryImageView.identifier)
        register(GalleryAddButton.self, forCellWithReuseIdentifier: GalleryAddButton.identifier)

        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func loadImage(remoteId: UUID) {
        if let image = Self.imagesCache[remoteId], cacheImages {
            let galleryImage = GalleryImage(id: remoteId, image: image, remoteId: remoteId, state: .ready)
            self.selectedImages = self.selectedImages.map { img in
                if img == galleryImage {
                    return galleryImage
                }
                return img
            }
            self.apply()
        } else {
            entityFilesService.loadImage(id: remoteId) { result in
                var galleryImage: GalleryImage!
                switch result {
                case .success(let image):
                    Self.imagesCache[remoteId] = image
                    galleryImage = GalleryImage(id: remoteId, image: image, remoteId: remoteId, state: .ready)
                case .failure(let error as NSError):
                    if self.parentViewController.isUnauthorized(error) {
                        NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                        return
                    }
                    galleryImage = GalleryImage(id: remoteId, image: nil, remoteId: remoteId, state: .downloadError)
                }

                garanteeMainThread {
                    self.selectedImages = self.selectedImages.map { img in
                        if img == galleryImage {
                            return galleryImage
                        }
                        return img
                    }
                    self.apply()
                }
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint?.constant = collectionViewLayout.collectionViewContentSize.height
        self.layoutIfNeeded()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        layer.cornerRadius = 5
        backgroundColor = .clear
        addSubview(loadingIndicator)
        loadingIndicator.fillSuperView()
        if let imagesIds = Self.galleryCache[self.entityId], cacheImages {
            self.onFetchImages(imagesIds)
            self.selectedImages = imagesIds.map { imageId in
                GalleryImage(id: imageId, image: nil, remoteId: imageId, state: .downloading)
            }
            self.apply()
            imagesIds.forEach { self.loadImage(remoteId: $0) }
        } else {
            startLoading()
            entityFilesService.getImages(fromEntity: entityId) { result in
                garanteeMainThread {
                    self.stopLoading()
                    switch result {
                    case .success(let imagesIds):
                        Self.galleryCache[self.entityId] = imagesIds
                        self.onFetchImages(imagesIds)
                        self.selectedImages = imagesIds.map { imageId in
                            GalleryImage(id: imageId, image: nil, remoteId: imageId, state: .downloading)
                        }
                        self.apply()
                        imagesIds.forEach { self.loadImage(remoteId: $0) }
                    case .failure(let error as NSError):
                        if self.parentViewController.isUnauthorized(error) {
                            NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                            return
                        }
                        Toast.present(in: self.parentViewController, message: error.domain)
                    }
                }
            }
        }
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
    }

    private func startLoading() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }

    private func stopLoading() {
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
    }

    private func makeDataSource() -> DataSource {
        DataSource(
            collectionView: self,
            cellProvider: { (collectionView, indexPath, image) -> UICollectionViewCell? in
                if indexPath.item == 0 && !self.readOnly {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryAddButton.identifier, for: indexPath) as? GalleryAddButton
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryImageView.identifier, for: indexPath) as? GalleryImageView
                    cell?.configure(with: image, readOnly: self.readOnly)
                    cell?.delegate = self
                    return cell
                }
            }
        )
    }

    func apply() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        if self.readOnly {
            if selectedImages.isEmpty {
                backgroundColor = UIColor.appBackgroundCell.withAlphaComponent(0.6)
                backgroundView = UILabel.build(withSize: 13,
                                               color: UIColor.appTitle.withAlphaComponent(0.7),
                                               alignment: .center,
                                               text: "Sem anexos para o objeto")
            } else {
                backgroundColor = .clear
                backgroundView = nil

            }
            snapshot.appendItems(selectedImages)
        } else {
            snapshot.appendItems([mockedImage] + selectedImages)
        }
        
        imagesDataSource.apply(snapshot, animatingDifferences: true, completion: {
            let itemsCount = self.selectedImages.count
            if itemsCount > 0 {
                self.selectedImages.forEach { image in
                    guard let index = snapshot.indexOfItem(image),
                          let indexPath = Optional(IndexPath(item: index, section: 0)),
                          let imageCell = self.cellForItem(at: indexPath) as? GalleryImageView,
                          let galleryImage = self.imagesDataSource.itemIdentifier(for: indexPath) else {
                        return
                    }
                    imageCell.configure(with: galleryImage, readOnly: self.readOnly)
                }
            }
        })
    }

    private func openPicker(for type: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return }

        self.imagePicker.sourceType = type
        self.parentViewController.present(self.imagePicker, animated: true)
    }

    func galleryConfiguration() -> GalleryConfiguration {
        [
            .closeButtonMode(.custom(imageViewerBtn)),
            .deleteButtonMode(.none),
            .thumbnailsButtonMode(.none),

            .pagingMode(.standard),
            .presentationStyle(.displacement),
            .hideDecorationViewsOnLaunch(false),

            .swipeToDismissMode(.vertical),

            .maximumZoomScale(8),
            .blurDismissDuration(0.1),
            .colorDismissDuration(0.2),
            .blurDismissDelay(0)
        ]
    }

    private func showGalleryImageViewer(at image: GalleryImage) {
        guard let displacedViewIndex = selectedImages.firstIndex(where: { $0 == image }) else { return }

        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let footerView = GalleryCounterView(frame: frame, currentIndex: displacedViewIndex, count: selectedImages.count)

        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDataSource: self, configuration: galleryConfiguration())
        galleryViewController.footerView = footerView
        galleryViewController.landedPageAtIndexCompletion = { index in
            footerView.count = self.selectedImages.count
            footerView.currentIndex = index
        }

        self.parentViewController.presentImageGallery(galleryViewController)
    }

    private func setNeedUpdateDetails() {
        if let detailsPage = self.parentViewController as? OccurrenceUpdateViewController<DrugUpdate> {
            detailsPage.needUpdateDetails = true
        }
        if let detailsPage = self.parentViewController as? OccurrenceUpdateViewController<InvolvedUpdate> {
            detailsPage.needUpdateDetails = true
        }
        if let detailsPage = self.parentViewController as? OccurrenceUpdateViewController<VehicleUpdate> {
            detailsPage.needUpdateDetails = true
        }
        if let detailsPage = self.parentViewController as? OccurrenceUpdateViewController<WeaponUpdate> {
            detailsPage.needUpdateDetails = true
        }
    }

    fileprivate func addImage(_ galleryImage: GalleryImage) {
        guard let image = galleryImage.image else { return }
        selectedImages = selectedImages.map { img in
            if img == galleryImage {
                return img.withState(.uploading)
            }
            return img
        }
        self.apply()

        entityFilesService.addImage(to: entityId, image: image) { result in
            garanteeMainThread {
                switch result {
                case .success(let fileId):
                    self.setNeedUpdateDetails()
                    self.selectedImages = self.selectedImages.map { img in
                        if img == galleryImage {
                            return GalleryImage(id: img.id, image: img.image, remoteId: fileId, state: .ready)
                        }
                        return img
                    }
                case .failure(let error as NSError):
                    if self.parentViewController.isUnauthorized(error) {
                        NotificationCenter.default.post(name: .userUnauthenticated, object: error)
                        return
                    }
                    self.selectedImages = self.selectedImages.map { img in
                        if img == galleryImage {
                            return GalleryImage(id: img.id, image: img.image, remoteId: img.remoteId, state: .uploadError)
                        }
                        return img
                    }
                }
                self.apply()
            }
        }
    }
}

extension GalleryView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let defaultSize = CGSize(width: 90, height: 90)
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return defaultSize }
        let spacing = flowLayout.minimumInteritemSpacing
        let viewWidth = collectionView.bounds.width
        let itemsPerRow: CGFloat = CGFloat(picturesPerRow)
        var itemSize = (viewWidth - itemsPerRow * spacing) / itemsPerRow
        itemSize = itemSize < 60 ? 60 : itemSize
        return CGSize(width: itemSize, height: itemSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 && !self.readOnly {
            let typePicker = MediaTypePickerViewController()
            typePicker.delegate = self
            parentViewController.present(typePicker, animated: true)
        } else {
            guard let image = imagesDataSource.itemIdentifier(for: indexPath) else { return }
            if image.state == .ready {
                showGalleryImageViewer(at: image)
            } else if image.state == .downloadError {
                guard let remoteId = image.remoteId else { return }
                loadImage(remoteId: remoteId)
            } else if image.state == .uploadError {
                addImage(image)
            }
        }
    }
}

extension GalleryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        parentViewController.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }

        let id = UUID()
        let galleryImage = GalleryImage(id: id, image: image, remoteId: nil, state: .uploading)
        self.selectedImages.insert(galleryImage, at: 0)
        self.apply()

        addImage(galleryImage)
    }
}

extension GalleryView: MediaPickerTypeDelegate, GalleryImageDelegate {
    func didSelectAType(_ type: MediaPickerType) {
        switch type {
        case .camera:
            openPicker(for: .camera)
        case .gallery:
            openPicker(for: .savedPhotosAlbum)
        }
    }

    func didRemoveAnImage(_ image: GalleryImage) {
        guard let imageId = image.remoteId else { return }
        startLoading()
        entityFilesService.removeImage(id: imageId) { error in
            garanteeMainThread {
                self.stopLoading()
                if error == nil {
                    self.setNeedUpdateDetails()
                    self.selectedImages.removeAll(where: { $0 == image })
                    self.apply()
                }
            }
        }
    }
}

extension GalleryView: GalleryItemsDataSource {
    func itemCount() -> Int { selectedImages.count }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        GalleryItem.image(fetchImageBlock: { imageCompletion in
            imageCompletion(self.selectedImages[index].image)
        })
    }
}
