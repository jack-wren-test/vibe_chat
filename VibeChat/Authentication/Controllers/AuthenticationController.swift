//
//  AuthenticationController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class AuthenticationController: UIViewController {
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CurrentUser.shared.isLoggedIn {
            presentHomeScreen(false)
        }
    }
    
    deinit {
        print("Authentication controller deinitialized")
    }
    
    // MARK:- Methods
    
    public func presentHomeScreen(_ isNewUser: Bool) {
        if let storyboard = storyboard {
            let homeController = storyboard.instantiateViewController(identifier: "HomeController") as! HomeController
            homeController.isNewUser = isNewUser
            let navController = UINavigationController(rootViewController: homeController)
            navController.modalPresentationStyle = .fullScreen
            dismiss(animated: true) {
                self.present(navController, animated: true)
            }
        }
    }
    
}
