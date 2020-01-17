//
//  HomeController+HomeDelegate.swift
//  VibeChat
//
//  Created by Jack Smith on 10/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension HomeController: HomeDelegate {
    
    func presentNewWindow(conversation: Conversation) {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "MessagesController") as! MessagesController
        vc.conversation = conversation
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func performLogOut() {
        CurrentUser.shared.logOut { (success) in
            if success {
                print("Succesfully logged out...")
                self.presentAuthenticationScreen()
            } else {
                print("Error logging out...")
            }
        }
    }
}
