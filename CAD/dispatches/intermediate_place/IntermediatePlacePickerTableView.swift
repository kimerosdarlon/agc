//
//  IntermediatePlacePickerTableView.swift
//  CAD
//
//  Created by Samir Chaves on 01/09/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit

class IntermediatePlaceViewModel: Hashable {
    let place: IntermediatePlace
    var selected = false
    var description: String?

    init(place: IntermediatePlace, selected: Bool = false, description: String? = nil) {
        self.place = place
        self.selected = selected
        self.description = description
    }

    static func == (lhs: IntermediatePlaceViewModel, rhs: IntermediatePlaceViewModel) -> Bool {
        lhs.place == rhs.place
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(place)
    }
}

class IntermediatePlacePickerTableView: UITableView {
    enum Section {
        case main
    }

    typealias DataSource = UITableViewDiffableDataSource<Section, IntermediatePlaceViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, IntermediatePlaceViewModel>
    private var placesDataSource: DataSource?
    private var places = [IntermediatePlaceViewModel]()
    var selectedPlaceCode: String?
    var selectedPlaceDescription: String? {
        guard let selectedPlaceIndex = places.firstIndex(where: { $0.place.code == selectedPlaceCode }) else { return nil }
        let indexPath = IndexPath(item: selectedPlaceIndex, section: 0)
        guard let placeCell = cellForRow(at: indexPath) as? IntermediatePlaceTableCell else { return nil }
        return placeCell.getDescription()
    }

    init(places: [IntermediatePlace], selectedPlaceCode: String?, selectedPlaceDescription: String?) {
        self.places = places.map { place in
            if place.code == selectedPlaceCode {
                return IntermediatePlaceViewModel(place: place, selected: true, description: selectedPlaceDescription)
            } else {
                return IntermediatePlaceViewModel(place: place)
            }
        }
        super.init(frame: .zero, style: .plain)
        placesDataSource = makeDataSource()
        register(IntermediatePlaceTableCell.self, forCellReuseIdentifier: IntermediatePlaceTableCell.identifier)
        dataSource = self.placesDataSource
        delegate = self
        self.selectedPlaceCode = selectedPlaceCode
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        tableFooterView = UIView()
        backgroundColor = .appBackground
        layoutMargins = .zero
        separatorInset = .zero
        canCancelContentTouches = false
        delaysContentTouches = false
        isExclusiveTouch = false
        estimatedRowHeight = 80
        rowHeight = UITableView.automaticDimension
        
        apply()
    }

    private func apply() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.places)
        placesDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func makeDataSource() -> DataSource {
        DataSource(
            tableView: self,
            cellProvider: { (tableView, indexPath, placeModel) -> IntermediatePlaceTableCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: IntermediatePlaceTableCell.identifier, for: indexPath) as? IntermediatePlaceTableCell
                cell?.configure(name: placeModel.place.description,
                                checked: placeModel.selected,
                                requiresDescription: placeModel.place.requiresDescription,
                                description: placeModel.description)
                cell?.selectionStyle = .none
                return cell
            }
        )
    }
}

extension IntermediatePlacePickerTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? IntermediatePlaceTableCell
        self.places.forEach { $0.selected = false }
        let selectedPlace = self.places[indexPath.row]
        if selectedPlace.place.requiresDescription {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cell?.focusOnDescriptionField()
            }
        }
        selectedPlace.selected = true
        selectedPlaceCode = selectedPlace.place.code
        apply()
    }
}
