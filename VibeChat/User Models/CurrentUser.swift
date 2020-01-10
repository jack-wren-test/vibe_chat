//
//  currentUser.swift
//  VibeChat
//
//  Created by Jack Smith on 16/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Singleton class for encapsulating the logged in user.
///
/// Access via '.shared' static property.
/// Performs log in and log out actions as well as user related network calls.
final class CurrentUser {
    
    // MARK:- Properties
    
    static var shared = CurrentUser()
    
    private var conversationsListener: ListenerRegistration?
    
    public var data: User?
    public var isLoggedIn: Bool {
        return data != nil ? true : false
    }
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    
    /// Log in a new user with credentials.
    /// - Parameters:
    ///   - withEmail: Email address
    ///   - andPassword: Password
    ///   - completion: Completion handler
    public func logIn(withEmail: String, andPassword: String, completion: @escaping ()->()) {
        AuthenticationManager.shared.logIn(email: withEmail, password: andPassword) { (user) in
            if let user = user {
                self.setCurrentUser(user)
                completion()
            }
        }
    }
    
    
    /// Log out current user.
    /// - Parameter completion: Completion handler returning success truth value
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
    
    
    /// Sets the current user if already logged in.
    /// - Parameter newUser: User object to set as the current user
    public func setCurrentUser(_ newUser: User) {
        data?.isOnline = true
        data = newUser
    }
    
    
    /// Clear current user details when logged out.
    private func nullifyUser() {
        conversationsListener?.remove()
        data?.isOnline = false
        data = nil
    }
    
    
    /// Upates the database counterpart for the current user with any changes.
    /// - Parameter completion: Optional completion handler with empty default implementation
    public func updateUserDataInDb(completion: @escaping (()->()) = {}) {
        guard let data = data else {return}
        UsersManager.shared.updateUserData(forUser: data, withData: data.toDict()) {
            completion()
        }
    }
    
    
    /// Fetches the current users conversations.
    /// - Parameter completion: Completion handler returning array of Conversation objects
    public func fetchConversations(completion: @escaping ([Conversation])->()) {
        guard let data = data else {return}
        UserMessagesManager.shared.fetchConversationList(forUser: data, completion: { (conversations) in
            if let conversations = conversations {
                completion(conversations)
            }
        })
    }
    
    
    /// Adds a listener to the current user which listens for changes in existing conversations.
    /// - Parameter completion: Completion handler returning array of Conversation objects (often a single changed conversation)
    public func listenToConversations(completion: @escaping ([Conversation])->()) {
        guard let data = data else {return}
        conversationsListener = UserMessagesManager.shared.listenToConversations(forUser: data) { (conversations) in
            completion(conversations)
        }
    }
    
}
