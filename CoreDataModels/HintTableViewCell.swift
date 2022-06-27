//
//  HintTableViewCell.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 24/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

public struct HintCellModel: Equatable {
    public let text: String
    public let module: String
    public var iconName: String
    public var date: Date
    public var searchQuery: [String: Any]?
    public var textExpanded: String?

    public init (text: String, module: String, iconName: String, date: Date) {
        self.text = text
        self.module = module
        self.iconName = iconName
        self.date = date
    }

    public static func from(model: CDRecents) -> HintCellModel {
        var hintCell = HintCellModel(text: model.text?.uppercased() ?? "", module: model.module ?? "", iconName: model.iconName ?? "", date: model.date ?? Date())
        if let data = model.searchString {
            hintCell.searchQuery = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        }
        hintCell.textExpanded = model.textExpanded
        return hintCell
    }

    public func isEqual(to other: HintCellModel ) -> Bool {
        return other.text.lowercased().elementsEqual(text.lowercased()) && other.module.lowercased().elementsEqual(module.lowercased())
    }

    public func notEqual(to other: HintCellModel ) -> Bool {
        return !isEqual(to: other)
    }

    public static func == (lhs: HintCellModel, rhs: HintCellModel) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}

public class HintTableViewCell: UITableViewCell {

    private let pattern = "\\s\\+\\d+$"
    private let labelFont = UIFont.robotoRegular.withSize(14)
    private lazy var gray: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: UIColor.appLightGray]
    private lazy var blue: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: UIColor.appBlue]
    var counter: NSMutableAttributedString?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(using model: HintCellModel, expanded: Bool) {
        if model.text.count == 0 { return }
        backgroundColor = .appBackground
        self.textLabel?.attributedText = getAttributedText(model, expanded: expanded)
        imageView?.image = getImageWith(name: model.iconName)
        accessoryType = expanded ? .disclosureIndicator : .none
        self.detailTextLabel?.text = expanded ? getDateFormated(model.date) : nil
        configureLabels()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.attributedText = nil
        detailTextLabel?.attributedText = nil
        counter = nil
    }

    func getAttributedText(_ model: HintCellModel, expanded: Bool) -> NSAttributedString {
        if model.text.matches(in: pattern) && !expanded {
            let counterStr = matches(for: pattern, in: model.text).first!
            counter = NSMutableAttributedString(string: counterStr, attributes: blue)
        }
        let middleText = model.module.isEmpty ? "" : " em "
        selectionStyle = model.module.isEmpty ? .none : .default
        var text = ""
        if expanded {
            text = model.textExpanded?.uppercased() ?? model.text.uppercased()
        } else {
            text = model.text.uppercased().replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
        }
        let finalText = NSMutableAttributedString(string: text, attributes: gray)
        let moduleName = NSAttributedString(string: model.module, attributes: blue)
        if counter != nil { finalText.append(counter!) }
        finalText.append( NSAttributedString(string: middleText, attributes: gray) )
        finalText.append(moduleName)
        return finalText
    }

    func getImageWith(name: String ) -> UIImage? {
        return  UIImage(systemName: name)?.withTintColor(.appLightGray, renderingMode: .alwaysOriginal)
    }

    func getDateFormated(_ date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.doesRelativeDateFormatting = true
        return timeFormatter.string(from: date )
    }

    func configureLabels() {
        textLabel?.numberOfLines = 0
        textLabel?.lineBreakMode = .byTruncatingMiddle
        textLabel?.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        detailTextLabel?.textColor = .appLightGray
        detailTextLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        detailTextLabel?.numberOfLines = 1
    }

    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
