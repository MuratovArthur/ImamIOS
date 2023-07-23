//// AppDelegate.swift
//
//import UIKit
//import CoreData
//
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    var window: UIWindow?
//
////    lazy var persistentContainer: NSPersistentContainer = {
////        let container = NSPersistentContainer(name: "ImamData") // Replace with your actual CoreData model name
////        container.loadPersistentStores { _, error in
////            if let error = error as NSError? {
////                fatalError("Unresolved error \(error), \(error.userInfo)")
////            }
////        }
////        return container
////    }()
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        return true
//    }
//
//    func applicationWillTerminate(_ application: UIApplication) {
//        self.saveContext()
//    }
//
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
//}
//
////import UIKit
////import CoreData
////
////class ImamAIAppDelegate: UIResponder, UIApplicationDelegate {
////
////    var window: UIWindow?
////
////    lazy var persistentContainer: NSPersistentContainer = {
////        let container = NSPersistentContainer(name: "ImamData") // Replace with your actual CoreData model name
////        container.loadPersistentStores { _, error in
////            if let error = error as NSError? {
////                fatalError("Unresolved error \(error), \(error.userInfo)")
////            }
////        }
////        return container
////    }()
////
////    // Access the managed object context from the app delegate
////    lazy var yourManagedObjectContext: NSManagedObjectContext = {
////        return persistentContainer.viewContext
////    }()
////
////    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
////        return true
////    }
////
////    func applicationWillTerminate(_ application: UIApplication) {
////        self.saveContext()
////    }
////
////    func saveContext () {
////        let context = persistentContainer.viewContext
////        if context.hasChanges {
////            do {
////                try context.save()
////            } catch {
////                let nserror = error as NSError
////                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
////            }
////        }
////    }
////}
