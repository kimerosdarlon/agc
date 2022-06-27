//
//  Repository.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 14/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import CoreData
import Logger

public protocol RepositoryProtocol {
    associatedtype Model
    func save(_ entity: Model)
    func getAll() -> [Model]
    func clearAll()
}

open class Repository<Entity>: NSObject, RepositoryProtocol {
    private lazy var logger = Logger.forClass(Self.self)
    private let version = 1
    private let manager: CoreDataManager

    public override init() {
        manager = CoreDataManager(modelFile: "Models")
    }

    open func save(_ entity: Entity) {
        fatalError("Method not implemented")
    }

    open func getAll() -> [Entity] {
        fatalError("Method not implemented")
    }

    public typealias Model = Entity

    public var context: NSManagedObjectContext {
        return manager.rootContext
    }

    public var persistentContainer: NSPersistentContainer {
        return self.manager.persistentContainer
    }

    open func clearAll() {
        fatalError("Method not implemented")
    }

    public func saveContext () {
        manager.saveContext()
    }
}

class CoreDataManager {
    private lazy var logger = Logger.forClass(Self.self)
    var persistentContainer: NSPersistentContainer!
    var managedObject: NSManagedObjectModel
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    var rootContext: NSManagedObjectContext!

    private var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for:
            .documentDirectory, in: .userDomainMask)
        let index = max(0, urls.count - 1)
        return urls[index] as NSURL
    }()

    init(modelFile: String, bundle: Bundle = Bundle(for: CoreDataManager.self) ) {

        let path = bundle.path(forResource: modelFile, ofType: "momd")
        let modelUrl = NSURL.fileURL(withPath: path!)
        managedObject = NSManagedObjectModel(contentsOf: modelUrl)!
        persistentContainer = NSPersistentContainer(name: modelFile, managedObjectModel: managedObject)
        let sqliteUrl = applicationDocumentsDirectory.appendingPathComponent(modelFile+".sqlite")!
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: managedObject)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteUrl, options: options)
            rootContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            rootContext.persistentStoreCoordinator = persistentStoreCoordinator
            rootContext.undoManager = UndoManager()
            persistentContainer.loadPersistentStores { (_, error) in
                if let error = error as NSError? {
                    self.logger.error(error.domain)
                }
            }
        } catch {
            fatalError("Não foi possível adicionar o persistence store")
        }
    }

    func saveContext () {

        if rootContext.hasChanges {
            do {
                try rootContext.save()
                 logger.debug("context saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            logger.debug("context has no changes")
        }
    }
}
