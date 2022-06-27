//
//  MultiselectorTagsView.swift
//  CAD
//
//  Created by Samir Chaves on 27/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

typealias SelectedTag<K: Hashable> = (label: String, value: K)

class SelectedTagHashable<K: Hashable>: Hashable {
    let label: String
    let value: K
    let color: UIColor

    init(tag: SelectedTag<K>, color: UIColor = .appBlue) {
        self.label = tag.label
        self.value = tag.value
        self.color = color
    }

    var tag: SelectedTag<K> {
        (label: label, value: value)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    public static func == (lhs: SelectedTagHashable, rhs: SelectedTagHashable) -> Bool {
        return lhs.value == rhs.value
    }

    func withColor(_ color: UIColor) -> SelectedTagHashable<K> {
        SelectedTagHashable<K>(tag: tag, color: color)
    }
}

class MultiselectorTagsCollectionView<K: Hashable>: UICollectionView, UICollectionViewDelegateFlowLayout {
    enum Section: Hashable { case main }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, SelectedTagHashable<K>>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SelectedTagHashable<K>>
    private typealias Cell = MultiselectorTagCell<K>

    private var tagsDataSource: DataSource!

    private var tags = [SelectedTagHashable<K>]()
    private let canBeEmpty: Bool
    private let tagsLayout = LeftAlignedFlowLayout(
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    )
    var colorForTag: (_: SelectedTag<K>) -> UIColor = { _ in .appBlue }

    private var heightConstraint: NSLayoutConstraint?

    var onRemoveASelection = { (selection: SelectedTag<K>, completion: @escaping (Bool) -> Void) in }

    init(tags: [SelectedTag<K>], canBeEmpty: Bool = true) {
        self.canBeEmpty = canBeEmpty
        self.tags = tags.map { SelectedTagHashable(tag: $0) }
        super.init(frame: .zero, collectionViewLayout: tagsLayout)

        self.tagsDataSource = makeDataSource()
        
        register(Cell.self, forCellWithReuseIdentifier: "MultiselectorTagCell")

        backgroundColor = .clear
        dataSource = tagsDataSource
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applySnapshot(completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(tags)
        tagsDataSource.apply(snapshot, animatingDifferences: true) {
            completion?()
        }
    }

    override func didMoveToSuperview() {
        self.applySnapshot()
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
    }

    private func makeDataSource() -> DataSource {
        DataSource(
            collectionView: self,
            cellProvider: { (collectionView, indexPath, selectedTag) -> Cell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "MultiselectorTagCell",
                    for: indexPath
                ) as? Cell
                cell?.backgroundColor = selectedTag.color
                let removable = self.tags.count > 1 || self.canBeEmpty
                cell?.configure(with: selectedTag.tag, removable: removable)
                cell?.closeBtn.tag = indexPath.row
                cell?.closeBtn.addTarget(self, action: #selector(self.didTapInCellCloseBtn(_:)), for: .touchUpInside)
                return cell
            }
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if tags.isEmpty {
            heightConstraint?.constant = 0
        } else {
            heightConstraint?.constant = collectionViewLayout.collectionViewContentSize.height
        }
        self.layoutIfNeeded()
    }

    @objc private func didTapInCellCloseBtn(_ sender: UIButton) {
        guard let button = sender as? IdentifiableButton<K> else { return }
        guard let row = tags.firstIndex(where: { $0.value == button.id }) else { return }
        let indexPath = IndexPath(row: row, section: 0)
        let cell = cellForItem(at: indexPath) as? Cell
        if let selectedTag = cell?.selectedTag {
            self.didRemove(tag: selectedTag)
        }
    }

    func update(with newTags: [SelectedTag<K>], completion: (() -> Void)? = nil) {
        tags = newTags.map { SelectedTagHashable(tag: $0, color: colorForTag($0)) }
        applySnapshot(completion: completion)
    }

    func didRemove(tag: SelectedTag<K>) {
        onRemoveASelection(tag) { shouldRemove in
            if shouldRemove {
                self.tags = self.tags.filter { $0.tag != tag }
                self.applySnapshot()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tag = tagsDataSource.itemIdentifier(for: indexPath) else { return .zero }
        let text = tag.label
        let attr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let title = NSString(string: text)
        let padding: CGFloat = 55 
        let size = CGSize(width: bounds.width - padding, height: 65)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        return CGSize(width: estimateFrame.width + padding, height: estimateFrame.height + 18)
    }
}
