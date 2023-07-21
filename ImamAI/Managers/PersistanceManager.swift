//
//  PersistenceManager.swift
//  ImamAI
//
//  Created by Muratov Arthur on 21.07.2023.
//

import Foundation
import CoreData

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private init() {} // Ensure it's a singleton
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NamazTime") // Replace with your .xcdatamodeld file name
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        })
        return container
    }()
    
    func setup() {
        // Add any additional setup logic here if needed
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error saving Core Data context: \(error)")
            }
        }
    }
}
