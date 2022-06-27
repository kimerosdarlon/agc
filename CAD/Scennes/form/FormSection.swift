//
//  SectionedForm.swift
//  CAD
//
//  Created by Samir Chaves on 27/01/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import Combine

enum FormFieldType {
    case tags, text, select, multiselect, date, datetime, checkbox, textarea
}

enum FormFieldState {
    case ready, loading, error(String), notFound
}

protocol GenericFormField: UIView {
    var type: FormFieldType { get }

    func getHeight() -> CGFloat
    func isFilled() -> Bool
    func clear()
    func getUserInput() -> String?
    func getTitle() -> String
}

protocol FormField: GenericFormField {
    associatedtype Value: Hashable
    func setSubject(_ subject: CurrentValueSubject<Value, Never>)
    func getSubject() -> CurrentValueSubject<Value, Never>?
}

class FormSectionHeader: UIView {
    private let titleLabel = UILabel.build(withSize: 17, color: .appTitle)
    private let subtitleLabel = UILabel.build(withSize: 12, alpha: 0.4, color: .appTitle, italic: true)
    private let countLabel: UILabel = {
        let label = UILabel.build(withSize: 13, weight: .bold, color: .white)
        label.backgroundColor = .appBlue
        let size: CGFloat = 17
        label.layer.masksToBounds = true
        label.width(size).height(size)
        label.textAlignment = .center
        label.layer.cornerRadius = size / 2
        return label
    }()
    fileprivate let chevron = UIImageView(
        image: UIImage(systemName: "chevron.down")?.withTintColor(.appTitle, renderingMode: .alwaysOriginal)
    ).enableAutoLayout()

    init(withTitle title: String, subtitle: String? = nil) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        backgroundColor = .appBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var onTap: () -> Void = { }

    @objc private func didTap() {
        onTap()
    }

    func setIsExpanded(_ isExpanded: Bool) {
        UIView.animate(withDuration: 0.2) {
//            let hasSubtitle = self.subtitleLabel.text != nil && !self.subtitleLabel.text!.isEmpty
            if isExpanded {
//                if hasSubtitle {
//                    self.subtitleLabel.alpha = 0
//                    self.titleLabel.transform = CGAffineTransform(translationX: 0, y: 11)
//                }
                self.chevron.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
            } else {
//                if hasSubtitle {
//                    self.titleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
//                    self.subtitleLabel.alpha = 0.4
//                }
                self.chevron.transform = CGAffineTransform.init(rotationAngle: 0)
            }
        }
    }

    func setFilledCount(_ count: Int) {
        if count == 0 {
            countLabel.isHidden = true
        } else {
            countLabel.text = "\(count)"
            countLabel.isHidden = false
        }
    }

    override func didMoveToSuperview() {
        let borderTop = UIView(frame: .zero).enableAutoLayout()
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(chevron)
        self.addSubview(countLabel)
        self.addSubview(borderTop)

        let didTap = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(didTap)

        borderTop.width(self).height(0.5)
        borderTop.backgroundColor = UIColor.appTitle.withAlphaComponent(0.02)
        if let subtitle = subtitleLabel.text, !subtitle.isEmpty {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -5),
                subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                subtitleLabel.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -15),
                subtitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -15),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

class FormFieldCell: UITableViewCell {
    static let identifier = String(describing: FormFieldCell.self)

    override func prepareForReuse() {
        super.prepareForReuse()
        subviews.forEach { $0.removeFromSuperview() }
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        contentView.isUserInteractionEnabled = false
        contentView.backgroundColor = .clear
    }

    func setup(field: UIView) {
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(field)
        field.clipsToBounds = true
        field.enableAutoLayout()
        field.backgroundColor = .appBackground
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            field.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            field.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        setNeedsLayout()
        layoutIfNeeded()
    }
}

class FormLine {
    fileprivate let fields: [GenericFormField]!
    var isHidden: Bool {
        didSet {
            view.isHidden = isHidden
        }
    }
    var view: UIView {
        if fields.count == 1 {
            return fields[0]
        }

        return FormView(fields: fields, horizontal: true)
    }

    init(_ fields: [GenericFormField], isHidden: Bool = false) {
        self.fields = fields
        self.isHidden = isHidden
    }

    init(_ field: GenericFormField, isHidden: Bool = false) {
        self.fields = [field]
        self.isHidden = isHidden
    }

    func getHeight() -> CGFloat {
        if let fields = fields {
            return fields.map { $0.getHeight() }.max() ?? 0
        } else {
            return 0
        }
    }
}

class FormSection {
    let title: String
    var lines = [FormLine]()
    var fields = [GenericFormField]()
    var disabled: Bool {
        didSet {
            if disabled {
                self.header?.chevron.alpha = 0.2
            } else {
                self.header?.chevron.alpha = 1
            }
        }
    }
    var isExpanded: Bool {
        didSet {
            self.header?.setIsExpanded(isExpanded)
        }
    }
    var isStatic: Bool
    private var fieldsFilled: Int = 0
    var header: FormSectionHeader?

    init(title: String, lines: [FormLine], isExpanded: Bool = false, isStatic: Bool = false, disabled: Bool = false, disabledMessage: String? = nil) {
        self.title = title
        self.lines = lines
        self.disabled = disabled
        self.isExpanded = isExpanded
        self.isStatic = isStatic
        if isStatic {
            self.header = nil
        } else {
            self.header = FormSectionHeader(withTitle: title, subtitle: disabledMessage)
            self.header?.setIsExpanded(isExpanded)
            self.header?.setFilledCount(0)
        }
        if disabled {
            self.header?.chevron.alpha = 0.2
        } else {
            self.header?.chevron.alpha = 1
        }
        for line in lines {
            self.fields.append(contentsOf: line.fields)
        }
    }

    func updateFillCount() {
        fieldsFilled = fields.filter { field in field.isFilled() }.count
        header?.setFilledCount(fieldsFilled)
    }

    func getInfo() -> [String: String] {
        var info = [String: String?]()
        for field in fields {
            info[field.getTitle()] = field.getUserInput()
        }

        let keysToRemove = info.keys.filter { info[$0]! == nil || info[$0]!!.isEmpty || info[$0]!!.trimmingCharacters(in: .whitespaces).isEmpty }

        for key in keysToRemove {
            info.removeValue(forKey: key)
        }

        let result = (info as? [String: String]) ?? [:]
        return result
    }
}
