//
//  UITableView+AgenteCampo.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 04/11/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {

    // set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
    public func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        self.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.frame.size =  header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.tableHeaderView = header
    }
}
