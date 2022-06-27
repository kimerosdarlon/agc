//
//  FieldConflict.swift
//  CAD
//
//  Created by Samir Chaves on 05/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import AgenteDeCampoCommon
import Foundation
import UIKit
import Combine

protocol GenericReadOnlyField: UIView { }

protocol ReadOnlyField: GenericReadOnlyField {
    associatedtype Value: Hashable

    var version: Int? { get set }
    var path: CurrentValueSubject<Value, Never>? { get }
}

class ROTagsField<K: Hashable>: UIView, ReadOnlyField {
    typealias Value = Set<K>

    private let tagsField: TagsFieldComponent<K>
    var path: CurrentValueSubject<Value, Never>?
    var version: Int?
    private let versionLabel = UILabel.build(withSize: 12, alpha: 0.7, color: .appTitle, italic: true)
    private let borderBottomView = UIView(frame: .zero).enableAutoLayout()

    required init(tags: [TagOption<K>]) {
        tagsField = TagsFieldComponent<K>(title: nil, fieldName: nil, tags: tags, multipleChoice: true)

        super.init(frame: .zero)

        if let version = version {
            versionLabel.text = "Versão \(version)"
        }
    
        path = tagsField.getSubject()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(versionLabel)
        addSubview(tagsField)
        addSubview(borderBottomView)

        borderBottomView.backgroundColor = UIColor.appTitle.withAlphaComponent(0.2)
        borderBottomView.width(self).height(1)

        tagsField.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            versionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            versionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            tagsField.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsField.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagsField.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 5),

            borderBottomView.topAnchor.constraint(equalTo: tagsField.bottomAnchor, constant: 4),

            bottomAnchor.constraint(equalTo: borderBottomView.bottomAnchor)
        ])
    }
}

class ROMultiselectorField<K: Hashable>: UIView, ReadOnlyField {
    typealias Value = [K]

    private let tagsField: TagsFieldComponent<K>
    var path: CurrentValueSubject<Value, Never>? = .init([])
    private var tagsSubject: CurrentValueSubject<Set<K>, Never>?
    private var subscription: AnyCancellable?
    var version: Int?
    private let versionLabel = UILabel.build(withSize: 12, alpha: 0.7, color: .appTitle, italic: true)
    private let borderBottomView = UIView(frame: .zero).enableAutoLayout()

    required init(tags: [TagOption<K>]) {
        tagsField = TagsFieldComponent<K>(title: nil, fieldName: nil, tags: tags, multipleChoice: true)
        tagsSubject = tagsField.getSubject()
        super.init(frame: .zero)

        if let version = version {
            versionLabel.text = "Versão \(version)"
        }

        subscription = path?.sink(receiveValue: { newValue in
            self.tagsSubject?.send(Set(newValue))
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(versionLabel)
        addSubview(tagsField)
        addSubview(borderBottomView)

        borderBottomView.backgroundColor = UIColor.appTitle.withAlphaComponent(0.2)
        borderBottomView.width(self).height(1)

        tagsField.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            versionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            versionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            tagsField.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsField.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagsField.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 5),

            borderBottomView.topAnchor.constraint(equalTo: tagsField.bottomAnchor, constant: 4),

            bottomAnchor.constraint(equalTo: borderBottomView.bottomAnchor)
        ])
    }
}

class ROGenericField<Input: Hashable>: UIView, ReadOnlyField {
    typealias Value = Input?

    private let textLabel = UILabel.build(withSize: 16, alpha: 0.8, color: .appTitle)
    private let versionLabel = UILabel.build(withSize: 12, alpha: 0.7, color: .appTitle, italic: true)
    var path: CurrentValueSubject<Value, Never>? = .init(nil)
    private var subscription: AnyCancellable?
    internal var version: Int?

    required init(transform: @escaping (Value) -> String?) {
        super.init(frame: .zero)

        subscription = path?.sink(receiveValue: { newValue in
            self.textLabel.text = transform(newValue)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setVersion(_ version: Int) {
       versionLabel.text = "Versão \(version)"
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(versionLabel)
        addSubview(textLabel)
        textLabel.layer.cornerRadius = 5
        textLabel.isUserInteractionEnabled = false
        textLabel.height(40)

        layer.borderWidth = 1
        layer.cornerRadius = 5
        layer.borderColor = UIColor.appTitle.cgColor.copy(alpha: 0.3)

        versionLabel.height(10)
        versionLabel.text = self.version.map { "Versão \($0)" }

        NSLayoutConstraint.activate([
            versionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            versionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            versionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            textLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 15),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7)
        ])
    }
}
