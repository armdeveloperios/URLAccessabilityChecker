//
//  CoreDataManager.swift
//  AccessibilityURLs
//
//  Created by Armen Alikhanyan on 3/22/19.
//  Copyright © 2019 Armen Alikhanyan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    // MARK: - Properties
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AccessibilityURLs")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    // MARK: - Private init
    private override init() {}
    
    // MARK: - Public API
    func add(model: URLModel) {
        guard let entity = NSEntityDescription.entity(forEntityName: "DataModel", in: managedContext) else {
            debugPrint("Can not get entity for add model")
            return
        }
        let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
        managedObject.setValue(model.duringTime, forKeyPath: duringTime)
        managedObject.setValue(model.urlString, forKeyPath: stringURL)
        managedObject.setValue(model.urlType.rawValue, forKeyPath: urlType)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            debugPrint("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func update(model: URLModel) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "DataModel")
        fetchRequest.predicate = NSPredicate(format: "stringURL = %@", model.urlString)
        
        do {
            let managedObjects = try managedContext.fetch(fetchRequest)
            guard let managedObject = managedObjects[0] as? NSManagedObject else {
                debugPrint("Can not get managed object for update model")
                return
            }
            managedObject.setValue(model.urlType.rawValue, forKeyPath: urlType)
            managedObject.setValue(model.duringTime, forKeyPath: duringTime)
            do {
                try managedContext.save()
            }
        } catch let error {
           debugPrint(error.localizedDescription)
        }
    }
    
    func delate(model: URLModel) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "DataModel")
        fetchRequest.predicate = NSPredicate(format: "stringURL = %@",model.urlString)
        do {
            let managedObjects = try managedContext.fetch(fetchRequest)
            guard let managedObject = managedObjects[0] as? NSManagedObject else {
                debugPrint("Can not get managed object for delete model")
                return
            }
            managedContext.delete(managedObject)
            do {
                try managedContext.save()
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func getModels() -> [URLModel] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "DataModel")
        var urls = [URLModel]()
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                guard let urlString = data.value(forKey: stringURL) as? String,
                    let type = data.value(forKey: urlType) as? Int,
                    let duringTime = data.value(forKey: duringTime) as? Double else {
                        debugPrint("Can not get all models from core data")
                        return urls
                }
                urls.append(URLModel(urlString, URLType(rawValue: type), duringTime))
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return urls
    }
    
    // MARK: - Private API
    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
