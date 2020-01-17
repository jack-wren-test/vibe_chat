//
//  AuthenticationController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

@objc protocol LoginDelegate {
    func presentHomeScreen(_ isNewUser: Bool)
}

/// The controller for the authentication home screen.
final class AuthenticationHomeController: UIViewController, LoginDelegate {
    
    // MARK:- Properties
    
    var isAlreadyLoggedIn = false
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CurrentUser.shared.isLoggedIn {
            self.isAlreadyLoggedIn = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isAlreadyLoggedIn {
            self.isAlreadyLoggedIn = !self.isAlreadyLoggedIn
            self.presentHomeScreen(false)
        }
    }
    
    deinit {
        print("Authentication controller deinitialized")
    }
    
    // MARK:- Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AuthenticateController
        vc.delegate = self
    }
    
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
