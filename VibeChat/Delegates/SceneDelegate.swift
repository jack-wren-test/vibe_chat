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
    var user: User?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        var initialTimer: Timer?
        initialTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (_) in
            initialTimer = nil
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        AuthenticationManager.shared.checkForValidUser { (user) in
            let homeController = storyboard.instantiateViewController(identifier: "HomeController") as! HomeController
            if user != nil {
                self.user = user
                UsersManager.shared.fetchChatters(ommitingCurrentUser: self.user!) { (chatters) in
                    if let chatters = chatters {
                        homeController.chatters = chatters
                        homeController.user = self.user
                        homeController.authenticationNeeded = false
                    }
                }
            }
            if initialTimer == nil {
                navController.popViewController(animated: true)
                navController.pushViewController(homeController, animated: true)
            } else {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    navController.popViewController(animated: true)
                    navController.pushViewController(homeController, animated: true)
                }
            }
        }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        user?.isOnline = false
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        user?.isOnline = true
    }

    func sceneWillResignActive(_ scene: UIScene) {
        user?.isOnline = false
    }
    
}

