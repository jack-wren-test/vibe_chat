//
//  SceneDelegate.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { print("No window scene??"); return }
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        
        AuthenticationManager.shared.checkForValidUser { (user) in
            if let user = user {
                CurrentUser.shared.setCurrentUser(user)
            }
            let authenticationController = storyboard.instantiateViewController(identifier: "AuthenticationController") as! AuthenticationHomeController
            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = authenticationController
            self.window?.makeKeyAndVisible()
        }
    }
    
    // App status functions for mornitoring user online staus if exists

    func sceneDidDisconnect(_ scene: UIScene) {
        CurrentUser.shared.data?.isOnline = false
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        CurrentUser.shared.data?.isOnline = true
    }

    func sceneWillResignActive(_ scene: UIScene) {
        CurrentUser.shared.data?.isOnline = false
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        CurrentUser.shared.data?.isOnline = false
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        CurrentUser.shared.data?.isOnline = true
    }
    
}

