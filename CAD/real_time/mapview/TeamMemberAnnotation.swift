//
//  TeamMemberAnnotation.swift
//  CAD
//
//  Created by Samir Chaves on 11/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class TeamMemberAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)

    var memberCpf: String
    var teamId: UUID
    var equipment: Equipment?
    var memberName: String
    var title: String?
    var subtitle: String?

    enum PresentationState {
        case equipment, member
    }
    var presentationState: PresentationState = .equipment

    required init(memberCpf: String, teamId: UUID, memberName: String, equipment: Equipment?) {
        self.memberCpf = memberCpf
        self.teamId = teamId
        self.memberName = memberName
        self.equipment = equipment
        super.init()
    }

    func updatePosition(_ position: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.coordinate = position
        }
    }
}

class TeamMemberAnnotationView: MKAnnotationView {
    static let identifier = "TeamMemberAnnotation"
    private static let pinSize: CGFloat = 25

    internal var arrow: AnnotationArrow

    internal let pin: UIImageView = {
        let pinSize: CGFloat = TeamMemberAnnotationView.pinSize
        let view = UIImageView(frame: .init(x: -pinSize / 2, y: -pinSize / 2, width: pinSize, height: pinSize))
        view.image = MemberViewModel.defaultImage
        view.layer.cornerRadius = pinSize / 2
        view.layer.borderWidth = 2
        view.backgroundColor = .gray
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel = UILabel.build(withSize: 9, alpha: 1, weight: .bold, color: .appTitle, alignment: .center)
    private let subtitleLabel = UILabel.build(withSize: 8, alpha: 0.9, weight: .bold, color: .appTitle, alignment: .center)
    private let labelsContainer = UIView(frame: .zero).enableAutoLayout()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        arrow = AnnotationArrow(
            frame: .init(x: -10, y: 8, width: 20, height: 13),
            color: CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        )
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        pin.layer.borderColor = CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        pin.backgroundColor = .gray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        addSubview(arrow)
        addSubview(pin)
        addSubview(labelsContainer)
        labelsContainer.addSubview(titleLabel)
        labelsContainer.addSubview(subtitleLabel)
        labelsContainer.isHidden = true
        collisionMode = .circle

        transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: TeamMemberAnnotationView.pinSize)
            .scaledBy(x: 0, y: 0)

        UIView.animate(withDuration: 0.4, delay: 0.2) {
            self.transform = CGAffineTransform.identity
        }

        labelsContainer.centerX().width(100)
        titleLabel.centerX().width(100)
        subtitleLabel.centerX().width(100)
        NSLayoutConstraint.activate([
            labelsContainer.topAnchor.constraint(equalTo: arrow.bottomAnchor, constant: 7.5),
            titleLabel.topAnchor.constraint(equalTo: labelsContainer.topAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            labelsContainer.bottomAnchor.constraint(equalTo: subtitleLabel.bottomAnchor)
        ])
    }

    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? TeamMemberAnnotation else {
              return
            }
            configure(with: annotation)
        }
    }

    func configure(with annotation: TeamMemberAnnotation) {
        image = nil
        canShowCallout = false
        let pinSize: CGFloat = TeamMemberAnnotationView.pinSize
        centerOffset = .init(x: 0, y: -pinSize)
        titleLabel.text = annotation.title
        switch annotation.presentationState {
        case .equipment:
            self.subtitleLabel.text = annotation.equipment?.formatName()
        case .member:
            self.subtitleLabel.text = annotation.memberName
        }
    }

    func hideLabel() {
        labelsContainer.fadeOut()
    }

    func showLabel() {
        labelsContainer.fadeIn()
    }

    func updateSubtitle() {
        guard let annotation = self.annotation as? TeamMemberAnnotation else { return }

//        subtitleLabel.fadeOut(duration: 0.2, completion: {
            switch annotation.presentationState {
            case .equipment:
                self.subtitleLabel.text = annotation.equipment?.formatName()
            case .member:
                self.subtitleLabel.text = annotation.memberName
            }
//            self.subtitleLabel.fadeIn()
//        })
    }
}
