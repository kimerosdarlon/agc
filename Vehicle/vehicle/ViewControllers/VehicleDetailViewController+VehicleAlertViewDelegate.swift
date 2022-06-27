//
//  VehicleDetailViewController+VehicleAlertViewDelegate.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 19/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

extension VehicleDetailViewController: VehicleAlertViewDelegate {

    func expandButtonDidClickWith(state expanded: Bool) {
        if expanded {
            self.colapseAlert(height: alertHeightColapsed)
        } else {
            self.expandAlert(height: alertHeightExpanded)
        }
    }

    func expandAlert( height: CGFloat ) {
        logger.debug("Altura => \(height)")
        if vehicleDetail.alert != nil {
            self.decreaseHeaderHeightToTop(headerAnimationTime)
        }
        alertHeightConstraint.constant = height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {
            NSLayoutConstraint.activate([self.alertHeightConstraint])
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func colapseAlert( height: CGFloat ) {
        alertHeightConstraint.constant = height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {
            NSLayoutConstraint.activate([self.alertHeightConstraint])
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func showHistoric() {
        let subtile = vehicleDetail.alert?.occurrenceBulletin?.system ?? ""
        let controller = HistoricViewController(title: "Histórico", subTitle: "Fonte: \(subtile)",
                                                text: vehicleDetail.alert?.occurrenceBulletin?.historic)
        present(controller, animated: true, completion: nil)
    }
}
