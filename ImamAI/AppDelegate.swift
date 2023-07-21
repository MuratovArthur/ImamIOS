
//
//  AppDelegate.swift
//  ChatViewTutorial
//
//  Created by Duy Bui on 2/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit
import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Core Data stack
        PersistenceManager.shared.setup()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes when the app is about to terminate
        PersistenceManager.shared.saveContext()
    }
}
