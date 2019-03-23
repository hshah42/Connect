//
//  Firebase.swift
//  
//
//  Created by Hem shah on 11/03/19.
//

import UIKit
import Firebase

class Firebase: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {
            FirebaseApp.configure()
            return true
    }
}
