//
//  currentUser.swift
//  VibeChat
//
//  Created by Jack Smith on 16/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

// THINK ABOUT HOW WE CAN BETTER USE ENCAPSULATION HERE AND IN THE USER CLASS

final class CurrentUser {
    
    // MARK:- Singleton Setup
    
    static var shared = CurrentUser()
    
    private var conversationsListener: ListenerRegistration?
    
    public var data: User?
    public var isLoggedIn: Bool {
        return data != nil ? true : false
    }
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Public Methods
    
    public func logIn(withEmail: String, andPassword: String, completion: @escaping ()->()) {
        AuthenticationManager.shared.logIn(email: withEmail, password: andPassword) { (user) in
            if let user = user {
                self.setNewUser(user)
                completion()
            }
        }
    }
    
    public func logOut(completion: @escaping (Bool)->()) {
        nullifyUser()
        AuthenticationManager.shared.logOut { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func setNewUser(_ newUser: User) {
        data?.isOnline = true
        data = newUser
    }
    
    public func nullifyUser() {
        conversationsListener?.remove()
        data?.isOnline = false
        data = nil
    }
    
    public func updateUserDataInDb(completion: @escaping (()->()) = {}) {
        guard let data = data else {return}
        UsersManager.shared.updateUserData(toUserUid: data.uid, withData: data.toDict()) {
            completion()
        }
    }
    
    public func fetchConversations(completion: @escaping ([Conversation])->()) {
        guard let data = data else {return}
        UserMessagesManager.shared.fetchConversationList(user: data, completion: { (conversations) in
            if let conversations = conversations {
                completion(conversations)
            }
        })
    }
    
    public func listenToConversations(completion: @escaping ([Conversation])->()) {
        conversationsListener = UserMessagesManager.shared.listenToConversations { (conversations) in
            completion(conversations)
        }
    }
    
}
