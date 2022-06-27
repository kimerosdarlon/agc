//
//  TeamDispatchView.swift
//  CAD
//
//  Created by Samir Chaves on 08/12/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import MarqueeLabel
import UIKit

class TeamDispatchView: UIView {

    enum ViewState {
        case loading
        case error(error: Error)
        case success(occurrence: OccurrenceDetails)
    }

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    private var state: ViewState = .loading {
        didSet {
            switch state {
            case .error:
                showError()
                stopLoading()
            case .success(let occurrence):
                setupInfo(occurrence)
                stopLoading()
            case .loading:
                startLoading()
            }
        }
    }

    private var dispatch: TeamDispatch!

    private let loadingIndicator = UIActivityIndicatorView(style: .large).enableAutoLayout()

    init(dispatch: TeamDispatch) {
        super.init(frame: .zero)
        self.dispatch = dispatch
        switch UserStylePreferences.theme.style {
        case .dark:
            backgroundColor = UIColor.black.withAlphaComponent(0.3)
        case .light:
            backgroundColor = .white
        default:
            backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        layer.cornerRadius = 5
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var priorityView = OccurrencePriorityLabel().enableAutoLayout()
    private var timeLabel = UILabel.build(withSize: 12, alpha: 0.7)
    private var addressLabel = UILabel.build(withSize: 15, weight: .bold)
    private var naturesLabel = MarqueeLabel.init(frame: .init(x: 0, y: 0, width: 200, height: 30), duration: 10.0, fadeLength: 10.0)
    private var errorLabel = UILabel.build(withSize: 14, alpha: 0.7, color: .appRed, alignment: .center)

    func startLoading() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }

    func stopLoading() {
        loadingIndicator.stopAnimating()
    }

    func showError() {
        errorLabel.isHidden = false
    }

    func setupInfo(_ occurrence: OccurrenceDetails) {
        priorityView = priorityView.withPriority(occurrence.generalInfo.priority)
        let address = occurrence.address
        addressLabel.text = String.interpolateString(
            values: [address.street, address.number, address.city, address.state],
            separators: [", ", " - ", ", "]
        )
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let formattedString = formatter.date(from: dispatch.dateTime)?.difference(to: Date(), [.hour, .minute]).humanize() {
            timeLabel.text = formattedString
        }

        naturesLabel.text =
            occurrence.natures.map { $0.name }.joined(separator: " • ") +
            (occurrence.natures.count == 1 ? "" : " •")
    }

    func addSubViews() {
        addSubview(priorityView)
        addSubview(timeLabel)
        addSubview(addressLabel)
        addSubview(naturesLabel)
        addSubview(loadingIndicator)
        addSubview(errorLabel)
        errorLabel.isHidden = true
    }

    func layoutConstraints() {
        let padding: CGFloat = 10
        loadingIndicator.fillSuperView()
        NSLayoutConstraint.activate([
            priorityView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            priorityView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),

            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            addressLabel.topAnchor.constraint(equalTo: priorityView.bottomAnchor, constant: padding),
            addressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            addressLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            naturesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            naturesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            naturesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),

            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: padding)
        ])
    }

    func configure() -> TeamDispatchView {
        enableAutoLayout()
        addSubViews()
        layoutConstraints()

        naturesLabel.enableAutoLayout()
        naturesLabel.font = UIFont.systemFont(ofSize: 12)
        naturesLabel.alpha = 0.7

        errorLabel.text = "Ocorreu um erro ao buscar o empenho. Tente novamente."

        state = .loading
        occurrenceService.getOccurrenceById(dispatch.occurrenceId) { result in
            garanteeMainThread {
                switch result {
                case .success(let occurrence):
                    self.state = .success(occurrence: occurrence)
                case .failure(let error):
                    self.state = .error(error: error)
                }
            }
        }

        return self
    }
}
