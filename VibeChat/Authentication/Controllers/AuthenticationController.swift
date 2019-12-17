//
//  AuthenticationController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class AuthenticationController: UIViewController {
    
    // MARK:- Properties
    
    var homeDelegate: HomeDelegate?
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AuthenticationController
        destination.homeDelegate = homeDelegate
    }
    
    public func presentHomeScreen() {
        let navController = self.presentingViewController?.presentingViewController as! UINavigationController
        UsersManager.shared.fetchChatters() { (chatters) in
            if let chatters = chatters {
                self.homeDelegate?.updateChatters(chatters: chatters)
                MessagesManager.shared.listenToConversationsForCurrentUser { (conversations) in
                    guard let conversations = conversations else {return}
                    self.homeDelegate?.updateConversations(conversations: conversations)
                }
            }
        }
        navController.dismiss(animated: true)
    }
    
}
