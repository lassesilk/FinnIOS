//
//  AppDelegate.swift
//  FinnIOS
//
//  Created by Lasse Silkoset on 25.02.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        CoreDataStack.sharedInstance.applicationDocumentsDirectory()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        CoreDataStack.sharedInstance.saveContext()
    }
    
  

}

