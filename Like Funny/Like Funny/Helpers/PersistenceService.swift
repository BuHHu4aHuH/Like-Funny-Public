 //
//  PersistenceService.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/24/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import Foundation
import CoreData
 
 class PersistenceServce {
    // MARK: - Core Data stack
    
    private init() {
        
    }
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Like_Funny")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("Saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
 }
