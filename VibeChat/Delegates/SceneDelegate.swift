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
            if let user = user {
                UsersManager.shared.fetchChatters(ommitingCurrentUser: user) { (chatters) in
                    if let chatters = chatters {
                        homeController.chatters = chatters
                        homeController.user = user
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
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
}
