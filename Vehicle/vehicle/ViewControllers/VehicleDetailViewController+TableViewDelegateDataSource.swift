//
//   VehicleDetailViewController+TableViewDelegateDataSource.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 19/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

extension VehicleDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: LocationTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! LocationTableViewCell
        cell.configure(with: locations[indexPath.item])
        let color = (indexPath.item % 2 == 0) ? UIColor.appBackground : UIColor.appBackgroundCell
        cell.setBackground(color: color)
        cell.setPosition(locations.count - indexPath.item)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = locations[indexPath.item]
        let width = tableView.frame.width * 0.9
        let attr = [NSAttributedString.Key.font: UIFont.robotoMedium.withSize(17)]
        let title = NSString(string: item.local )
        let size = CGSize(width: width, height: 1000)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        return CGSize.init(width: width, height: estimateFrame.height + 75).height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return .init()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedLocation = locations[indexPath.item]
        self.gotoNavigation()
    }
}
