//
//  AppDelegate.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Check if there is a user logged in
        // Retrive user data
        // Pass to Home Controller
        // Move to loading screen until callback is performed
        // If it takes longer than 10 seconds, time out and display error to user
        
//        let storyboard = UIStoryboard.init(name: "Main.storyboard", bundle: .main)
//        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        
        return true
    }
    
//    fileprivate func checkForUser() -> Bool {
//        Authenticate.shared.checkForValidUser { (presentAuthenticateScreen) in
//            if presentAuthenticateScreen {
//            }
//        }
//    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

