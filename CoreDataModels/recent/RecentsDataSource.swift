//
//  RecentsService.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 13/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import CoreData
import Logger
import AgenteDeCampoCommon

public protocol RecentsDataSourceObserver: class {
    func didChangeDataBase()
}

public class RecentsDataSource: Repository<HintCellModel> {
    private lazy var logger = Logger.forClass(Self.self)
    private let key = "recentsCell"
    private static var data = [HintCellModel]()
    private var resultsController: NSFetchedResultsController<CDRecents>!
    public weak var observer: RecentsDataSourceObserver?
    private let table: UITableView?

    public init(table: UITableView? = nil) {
        self.table = table
        super.init()
        self.table?.dataSource = self
        let request: NSFetchRequest<CDRecents> = CDRecents.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortByDate]
        let section = table != nil ?  "computedDate" : nil
        resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: section, cacheName: nil)
        resultsController.delegate = self
        try? resultsController.performFetch()
    }

    public func reloadData() {
        try? resultsController.performFetch()
    }

    public func deletIfExist(_ element: HintCellModel) {
        let request: NSFetchRequest<CDRecents> = CDRecents.fetchRequest()
        request.predicate = NSPredicate(format: "text = [c] %@ && module = %@", element.text, element.module)
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortByDate]
        guard let all = try? context.fetch(request) else {return}
        for older in all {
            context.delete(older)
            saveContext()
        }
        observer?.didChangeDataBase()
    }

    public override func save(_ element: HintCellModel ) {
        deletIfExist(element)
        let name = String(describing: CDRecents.self)
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        let recent = CDRecents(entity: entity, insertInto: context)
        recent.date = element.date
        recent.iconName = element.iconName
        recent.text = element.text
        recent.module = element.module
        recent.textExpanded = element.textExpanded
        let data = try? JSONSerialization.data(withJSONObject: element.searchQuery ?? [:], options: [.prettyPrinted])
        recent.searchString = data
        saveContext()
        observer?.didChangeDataBase()
    }

    public func deletIfExist(_ element: Recent) {
        let request: NSFetchRequest<CDRecents> = CDRecents.fetchRequest()
        request.predicate = NSPredicate(format: "text = [c] %@ && module = %@", element.text, element.module)
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortByDate]
        guard let all = try? context.fetch(request) else {return}
        for older in all {
            context.delete(older)
            saveContext()
        }
        observer?.didChangeDataBase()
    }

    public func save(_ recent: Recent) {
        deletIfExist(recent)
        let name = String(describing: CDRecents.self)
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        let cdRecent = CDRecents(entity: entity, insertInto: context)
        cdRecent.date = recent.date
        cdRecent.iconName = recent.iconName
        cdRecent.text = recent.text
        cdRecent.module = recent.module
        cdRecent.textExpanded = recent.textExpanded
        let data = try? JSONSerialization.data(withJSONObject: recent.searchString ?? [:], options: [.prettyPrinted])
        cdRecent.searchString = data
        saveContext()
        observer?.didChangeDataBase()
    }

    public override func getAll() -> [HintCellModel] {
        let request: NSFetchRequest<CDRecents> = CDRecents.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortByDate]
        guard let all = try? context.fetch(request) else {
            return []
        }
        return all.map({ HintCellModel.from(model: $0) })
    }

    public override func clearAll() {
        let request: NSFetchRequest<CDRecents> = CDRecents.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortByDate]
        guard let all = try? context.fetch(request) else { return }
        all.forEach({ context.delete($0)})
        saveContext()
        NotificationCenter.default.post(name: .clearRecents, object: nil, userInfo: nil)
        observer?.didChangeDataBase()
    }

    public func delete(at index: IndexPath) {
        let recent = resultsController.object(at: index)
        context.delete(recent)
        saveContext()
    }

    public func deleteAll(in indexes: [IndexPath]) {
        let recents = indexes.map { resultsController.object(at: $0) }
        recents.forEach { object in
            context.delete(object)
        }
        saveContext()
    }
}

extension RecentsDataSource: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: key, for: indexPath) as! HintTableViewCell
        var hint = object(at: indexPath)
        hint.iconName = ""
        cell.configure(using: hint, expanded: true)
        cell.backgroundColor = .appBackgroundCell
        return cell
    }

    public func object(at indexPath: IndexPath) -> HintCellModel {
        return HintCellModel.from(model: resultsController.object(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let index = IndexPath(item: 0, section: section)
        let recent = resultsController.object(at: index)
        return recent.computedDate
    }
}

extension RecentsDataSource: NSFetchedResultsControllerDelegate {

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table?.beginUpdates()
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table?.endUpdates()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        guard let table = table else {
            return
        }

        switch type {
        case .delete:
            guard let index = indexPath else {return}
            table.deleteRows(at: [index], with: .left)
        case .insert:
            guard let index = newIndexPath else { return }
            table.insertRows(at: [index], with: .top)
        case .update:
            guard let index = indexPath else { return }
            table.reloadRows(at: [index], with: .fade)
        case .move:
            guard let index = indexPath else { return }
            guard let newIndex = newIndexPath else { return }
            table.deleteRows(at: [index], with: .left)
            table.insertRows(at: [newIndex], with: .left)
        @unknown default:
            logger.error("NOT IMPLEMENTED")
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            table?.deleteSections(IndexSet.init([sectionIndex]), with: .left)
        case .insert:
            table?.insertSections(IndexSet.init([sectionIndex]), with: .left)
        default:
            logger.error("NOT IMPLEMENTED")
        }
    }
}
