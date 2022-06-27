//
//  CadPackageDataStack.swift
//  CAD
//
//  Created by Samir Chaves on 06/05/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import CoreData

public class LocationPackageDataStack: NSObject {

    public static let shared = LocationPackageDataStack()

    private let identifier = "com.ramires.Location"
    private let model = "PositionEvents"

    private override init() {}

    public lazy var persistentContainer: NSPersistentContainer = {
        let messageKitBundle = Bundle(identifier: identifier)
        let modelURL = messageKitBundle!.url(forResource: model, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: model, managedObjectModel: managedObjectModel!)

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    public var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
}
