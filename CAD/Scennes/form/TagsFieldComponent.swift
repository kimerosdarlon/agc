//
//  TagsFieldComponent.swift
//  CAD
//
//  Created by Samir Chaves on 04/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon
import Combine

typealias TagOption<K: Hashable> = (key: K, value: String)

class TagOptionHashable<K: Hashable>: Hashable {
    let key: K
    let value: String

    init(tag: TagOption<K>) {
        self.key = tag.key
        self.value = tag.value
    }

    func toTag() -> TagOption<K> {
        return (key: key, value: value)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    public static func == (lhs: TagOptionHashable<K>, rhs: TagOptionHashable<K>) -> Bool {
        return lhs.key == rhs.key
    }
}

private class TagsHeaderView: UICollectionReusableView {
    public static let height: CGFloat = 20
    public static let identifier = String(describing: CollectionHeaderView.self)

    fileprivate let label = UILabel.build(withSize: 13, weight: .bold, color: .appTitle)

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(label)
        backgroundColor = .appBackground
        enableAutoLayout()
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

class TagsFieldComponent<K: Hashable>: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FormField {
    enum Section: Hashable {
        case main
    }
    typealias DataSource<Value: Hashable> = UICollectionViewDiffableDataSource<Section, TagOptionHashable<Value>>
    typealias Snapshot<Value: Hashable> = NSDiffableDataSourceSnapshot<Section, TagOptionHashable<Value>>
    typealias Value = Set<K>

    private var tagsDataSource: DataSource<K>!
    private var feedbackDataSource: DataSource<String>!

    private var heightConstraint: NSLayoutConstraint?

    internal var type: FormFieldType = .tags
    private var path: CurrentValueSubject<Set<K>, Never>?
    private var tags = [TagOptionHashable<K>]()
    var selected = Set<K>()
    private var tagsViews = [UIView]()
    private var title: String?
    private var fieldName: String
    private var subscription: AnyCancellable?
    private let showLabel: Bool
    private let tagsLayout = LeftAlignedFlowLayout(
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    )
    var onSelect: (TagOption<K>, [TagOption<K>]) -> Void = { (_, _) in }

    var state: FormFieldState {
        didSet {
            switch state {
            case .loading:
                setFeedbacks([(key: "loading", value: "Carregando...")])
                collectionViewLayout.collectionView?.alpha = 0.6
                isUserInteractionEnabled = false
                self.tags = []
            case .notFound:
                setFeedbacks([(key: "not_found", value: " Sem resultados  ")])
                collectionViewLayout.collectionView?.alpha = 0.6
                isUserInteractionEnabled = false
                self.tags = []
            case .ready:
                collectionViewLayout.collectionView?.alpha = 1
                isUserInteractionEnabled = true
            case .error(let message):
                setFeedbacks([(key: "error", value: message)])
                collectionViewLayout.collectionView?.alpha = 0.7
                isUserInteractionEnabled = false
                self.tags = []
            }
        }
    }

    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.robotoMedium.withSize(14)
        label.textColor = .appCellLabel
        label.textAlignment = .left
        label.enableAutoLayout()
        label.height(15)
        return label
    }()

    init(title: String? = nil, fieldName: String? = nil, tags: [TagOption<K>] = [], multipleChoice: Bool = true, showLabel: Bool = true) {
        self.fieldName = fieldName ?? title ?? ""
        self.state = .ready
        self.showLabel = showLabel
        super.init(frame: .zero, collectionViewLayout: tagsLayout)
        self.tagsDataSource = makeDataSource()
        self.feedbackDataSource = makeDataSource()

        register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        register(TagsHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TagsHeaderView.identifier)

        if !showLabel {
            tagsLayout.headerReferenceSize = CGSize(width: self.frame.size.width, height: 0)
        } else if title != nil {
            tagsLayout.headerReferenceSize = CGSize(width: self.frame.size.width, height: TagsHeaderView.height)
        }

        backgroundColor = .clear
        allowsMultipleSelection = multipleChoice
        delegate = self

        if !tags.isEmpty {
            dataSource = tagsDataSource
        }

        self.tags = tags.map { TagOptionHashable(tag: $0) }
        self.title = title
        self.path = .init([])
        subscription = self.path?.sink(receiveValue: { newValue in
            if newValue != self.selected {
                self.selected = newValue
            }
        })

        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
    }

    func highlightSelectedCells() {
        do {
            for indexPath in self.indexPathsForSelectedItems ?? [] {
                self.deselectItem(at: indexPath, animated: true)
                let cell = self.cellForItem(at: indexPath)
                cell?.backgroundView?.backgroundColor = .clear
            }

            let indexPaths: [IndexPath] = try selected.map { tagKey in
                guard let item = tags.firstIndex(where: { tag in
                    tag.key == tagKey
                }) else {
                    throw NSError(domain: "Tag does not exist in already configured tags", code: 0, userInfo: nil)
                }
                return IndexPath(item: item, section: 0)
            }
            indexPaths.forEach { indexPath in
                self.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                let cell = self.cellForItem(at: indexPath)
                cell?.backgroundView?.backgroundColor = .appBlue
            }
        } catch let error {
            print(error)
        }
    }

    func selectTags(_ selectedTags: Set<K>) {
        selected = selectedTags
        path?.send(selected)
        highlightSelectedCells()
    }

    func setTags(_ tags: [TagOption<K>]) {
        if tags.isEmpty {
            self.state = .notFound
        } else {
            self.state = .ready
            dataSource = tagsDataSource
            self.tags = tags.map { TagOptionHashable(tag: $0) }
            self.applySnapshot(on: tagsDataSource, withTags: self.tags)
        }
    }

    func setFeedbacks(_ feedbacks: [TagOption<String>]) {
        dataSource = feedbackDataSource
        self.applySnapshot(on: feedbackDataSource, withTags: feedbacks.map { TagOptionHashable(tag: $0) })
    }

//    private func updateContentSize() {
//        let height = self.intrinsicContentSize.height
//        self.heightConstraint?.constant = height
//        print("collectionViewContentSize 2: ", height)
//        self.layoutIfNeeded()
//        self.invalidateIntrinsicContentSize()
//    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        update()
//        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
//        heightConstraint?.isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint?.constant = collectionViewLayout.collectionViewContentSize.height
        highlightSelectedCells()
        self.layoutIfNeeded()
    }

    func forceLayoutSubviews() {
        super.layoutSubviews()
        heightConstraint?.constant = self.intrinsicContentSize.height
        highlightSelectedCells()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func update() {
        self.applySnapshot(on: tagsDataSource, withTags: self.tags)
    }

    private func applySnapshot<Value: Hashable>(on dataSource: DataSource<Value>, withTags tags: [TagOptionHashable<Value>]) {
        var snapshot = Snapshot<Value>()
        snapshot.appendSections([.main])
        snapshot.appendItems(tags)
        dataSource.apply(snapshot, animatingDifferences: false) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.highlightSelectedCells()
            }
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareTagForText(cell: TagCell, for text: String) -> TagCell {
        cell.textLabel.text = text
        cell.textLabel.font = .systemFont(ofSize: 15)
        switch state {
        case .error:
            cell.textLabel.textColor = .appRed
        default:
            cell.textLabel.textColor = .appTitle
        }
        cell.layer.cornerRadius = 5

        let unselectedView = UIView()
        unselectedView.layer.borderWidth = 1
        unselectedView.layer.cornerRadius = 5
        unselectedView.layer.borderColor = UIColor.appTitle.withAlphaComponent(0.3).cgColor
        unselectedView.backgroundColor = .clear

        cell.backgroundView = unselectedView
        return cell
    }

    private func provideSupplementaryView<Item: Hashable>(in dataSource: DataSource<Item>) {
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let kind = UICollectionView.elementKindSectionHeader
            let identifier = TagsHeaderView.identifier
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as! TagsHeaderView

            if self.title != nil {
                header.frame.size.height = TagsHeaderView.height
                header.label.text = self.title
            } else {
                header.frame.size.height = 0
            }

            if !self.showLabel {
                header.frame.size.height = 0
                header.label.isHidden = true
            }
            return header
        }
    }

    private func makeDataSource<Value: Hashable>() -> DataSource<Value> {
        let dataSource = DataSource<Value>(
            collectionView: self,
            cellProvider: { (collectionView, indexPath, tag) -> TagCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell
                if let cell = cell {
                    return self.prepareTagForText(cell: cell, for: tag.value)
                }
                return nil
            }
        )
        provideSupplementaryView(in: dataSource)
        return dataSource
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tag = tagsDataSource.itemIdentifier(for: indexPath) else { return .zero }
        let text = tag.value
        let attr = [NSAttributedString.Key.font: UIFont.robotoMedium.withSize(15)]
        let title = NSString(string: text)
        let size = CGSize(width: 1100, height: 35)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        if estimateFrame.width > collectionView.bounds.width - 30 {
            return CGSize(width: collectionView.bounds.width - 15, height: 35)
        }
        return CGSize(width: estimateFrame.width + 30, height: 35)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = tagsDataSource.itemIdentifier(for: indexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? TagCell else { return }
        
        if selected.contains(tag.key) {
            cell.backgroundView?.backgroundColor = .clear
            cell.textLabel.textColor = .appCellLabel
            selected.remove(tag.key)
        } else {
            cell.backgroundView?.backgroundColor = .appBlue
            cell.textLabel.textColor = .white
            selected.insert(tag.key)
        }
        path?.send(selected)
        let selectedOptions = selected.map { tagKey in
            tags.filter { $0.key == tagKey }.first
        }
        onSelect(tag.toTag(), selectedOptions.compactMap { $0?.toTag() })
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TagCell else { return }
        cell.backgroundView?.backgroundColor = .clear
        cell.textLabel.textColor = .appCellLabel
        guard let tag = tagsDataSource.itemIdentifier(for: indexPath) else { return }
        selected.remove(tag.key)
        path?.send(selected)
        let selectedOptions = selected.map { tagKey in
            tags.filter { $0.key == tagKey }.first
        }
        onSelect(tag.toTag(), selectedOptions.compactMap { $0?.toTag() })
    }
}

extension TagsFieldComponent {
    func getHeight() -> CGFloat {
        return (heightConstraint?.constant ?? 0) + 20
    }

    func getUserInput() -> String? {
        let selectedOptions = selected.map { tagKey in
            tags.filter { $0.key == tagKey }.first?.value
        }
        return selectedOptions.compactMap { $0 }.joined(separator: ", ")
    }

    func clear() {
        selectTags([])
    }

    func isFilled() -> Bool {
        selected.count > 0
    }

    func getTitle() -> String {
        return fieldName.replacingOccurrences(of: ":", with: "")
    }

    func getSubject() -> CurrentValueSubject<Value, Never>? {
        self.path
    }

    func setSubject(_ subject: CurrentValueSubject<Value, Never>) {
        self.path = subject
    }
}
