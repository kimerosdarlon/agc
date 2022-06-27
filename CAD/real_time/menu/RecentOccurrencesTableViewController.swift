//
//  OccurrenceTableViewController.swift
//  CAD
//
//  Created by Samir Chaves on 11/03/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import AgenteDeCampoCommon
import Location
import UIKit
import MapKit
import CoreLocation

protocol RecentOccurrencesTableDelegate: class {
    func didSelectAnOccurrence(_ occurrence: SimpleOccurrence)
    func didDeselectAnOccurrence()
    func didZoomInOccurrence(_ occurrence: SimpleOccurrence)
    func didRefreshOccurrences(completion: @escaping (Error?) -> Void)
}

class RecentOccurrencesTableViewController: UITableViewController {
    private enum OccurrencesState {
        case success([SimpleOccurrence]), notFound, error(NSError), loading
    }

    private let spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView().enableAutoLayout()
        spinner.backgroundColor = .appBackground
        return spinner
    }()
    private let notFoundLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .appTitle
        label.alpha = 0.5
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "Nenhuma ocorrência encontrada."
        return label
    }()
    private let countLabel = UILabel.build(withSize: 12, alpha: 0.7, color: .appTitle)

    @OccurrenceServiceInject
    private var occurrenceService: OccurrenceService

    @CadServiceInject
    private var cadService: CadService

    private let locationService = LocationService.shared

    weak var delegate: RecentOccurrencesTableDelegate?

    private var state: OccurrencesState {
        didSet {
            switch state {
            case .loading:
                spinnerView.isHidden = false
                countLabel.isHidden = false
            case .notFound:
                stopLoading()
                occurrences = []
                tableView.backgroundView = notFoundLabel
                tableView.reloadData()
                countLabel.isHidden = false
            case .error:
                countLabel.isHidden = true
                stopLoading()
            case .success(let occurrences):
                stopLoading()
                tableView.backgroundView = nil
                self.occurrences = occurrences
                countLabel.isHidden = false
                if occurrences.count == 1 {
                    countLabel.text = "    1 ocorrência"
                } else {
                    countLabel.text = "    \(occurrences.count) ocorrências"
                }
                self.tableView.reloadData()
            }
        }
    }

    private var occurrences = [SimpleOccurrence]()

    private let rootViewController: UIViewController

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        state = .notFound
        super.init(nibName: nil, bundle: nil)
        title = "Ocorrências"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(spinnerView)
        tableView.tableHeaderView = countLabel.height(30)
        tableView.tableFooterView = UIView()
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.backgroundColor = .clear
        tableView.canCancelContentTouches = false
        tableView.delaysContentTouches = false
        tableView.isExclusiveTouch = false
        tableView.estimatedRowHeight = 178
        tableView.rowHeight = UITableView.automaticDimension

        spinnerView.fillSuperView()
        state = .notFound

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refreshTableView), for: .valueChanged)
    }

    @objc private func refreshTableView() {
        delegate?.didRefreshOccurrences { error in
            garanteeMainThread {
                if let error = error as NSError?, self.isUnauthorized(error) {
                    self.gotoLogin(error.domain)
                } else {
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }

    typealias OccurrenceSorting = (SimpleOccurrence, SimpleOccurrence) -> Bool

    func setOccurrences(_ occurrences: [SimpleOccurrence]) {
        if occurrences.isEmpty {
            state = .notFound
        } else {
            let userLocation = locationService.currentLocation
            let userTeamOperatingRegions = cadService.getActiveTeam()?.operatingRegions ?? []

            let generalAlertSorting: OccurrenceSorting = { ocr1, _ in ocr1.generalAlert }

            let prioritySorting: OccurrenceSorting = { $0.priority > $1.priority }

            let distanceSorting: OccurrenceSorting = { ocr1, ocr2 in
                guard let userLocation = userLocation else { return false }
                guard let location1 = ocr1.address.coordinates?.toCLLocation() else { return false }
                guard let location2 = ocr2.address.coordinates?.toCLLocation() else { return true }
                let distance1 = location1.distance(from: userLocation)
                let distance2 = location2.distance(from: userLocation)
                return distance1 < distance2
            }

            let operatingRegionSorting: OccurrenceSorting = { ocr1, _ in
                return userTeamOperatingRegions.contains(ocr1.operatingRegion)
            }

            let now = Date()
            let timeSorting: OccurrenceSorting = { ocr1, ocr2 in
                guard let time1 = ocr1.serviceRegisteredAt.toDate(format: "yyyy-MM-dd'T'HH:mm:ss") else { return false }
                guard let time2 = ocr2.serviceRegisteredAt.toDate(format: "yyyy-MM-dd'T'HH:mm:ss") else { return true }
                let time1SinceNow = time1.timeIntervalSince(now)
                let time2SinceNow = time2.timeIntervalSince(now)
                return time1SinceNow < time2SinceNow
            }

            let complementaryCountSorting: OccurrenceSorting = { $0.complementaryNumber > $1.complementaryNumber }

            let sortedOccurrences = occurrences.sorted(by:
                generalAlertSorting,
                prioritySorting,
                distanceSorting,
                operatingRegionSorting,
                timeSorting,
                complementaryCountSorting
            )
            state = .success(sortedOccurrences)
        }
    }

    func setError(_ error: NSError) {
        state = .error(error)
    }

    func startLoading() {
        self.state = .loading
    }

    private func stopLoading() {
        spinnerView.isHidden = true
    }
}

extension RecentOccurrencesTableViewController: RecentOccurrenceDelegate, RecentOccurrenceCellDelegate {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return occurrences.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = RecentOccurrenceTableViewCell.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RecentOccurrenceTableViewCell
        if cell == nil {
            cell = RecentOccurrenceTableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        cell?.delegate = self
        cell?.configure(using: occurrences[indexPath.item])
        return cell!
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 178
//    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOccurrence = occurrences[indexPath.item]
        delegate?.didSelectAnOccurrence(selectedOccurrence)
        let details = RecentOccurrenceViewController(occurrence: selectedOccurrence)
        details.delegate = self
        self.navigationController?.pushViewController(details, animated: true)
    }

    func didBack() {
        delegate?.didDeselectAnOccurrence()
    }

    func didTapInDetailsButton(_ occurrenceId: UUID, completion: @escaping () -> Void) {
        occurrenceService.getOccurrenceById(occurrenceId) { result in
            garanteeMainThread {
                switch result {
                case .success(let occurrenceDetails):
                    NotificationCenter.default.post(name: .cadDidDetailAnOccurrence, object: nil, userInfo: [
                        "details": occurrenceDetails
                    ])
                case .failure(let error as NSError):
                    if self.isUnauthorized(error) {
                        self.gotoLogin(error.domain)
                    } else if error.code == -1009 { // NSURLErrorDomain
                        Toast.present(in: self.rootViewController, message: "Não foi possível completar a requisição. Tente novamente.")
                    } else {
                        Toast.present(in: self.rootViewController, message: error.domain)
                    }
                }
                completion()
            }
        }
    }

    func didTapZoom(to occurrence: SimpleOccurrence) {
        delegate?.didZoomInOccurrence(occurrence)
    }
}
