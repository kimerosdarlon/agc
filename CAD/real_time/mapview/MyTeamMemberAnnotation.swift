//
//  MyTeamMemberAnnotation.swift
//  CAD
//
//  Created by Samir Chaves on 25/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import MapKit
import UIKit

final class MyTeamMemberAnnotation: TeamMemberAnnotation {}

class MyTeamMemberAnnotationView: TeamMemberAnnotationView {
    static let childIdentifier = "MyTeamMemberAnnotation"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        super.arrow.color = UIColor.appBlue.cgColor
        super.pin.layer.borderColor = UIColor.appBlue.cgColor
        super.pin.backgroundColor = UIColor.appBlue.darker(by: 0.2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
