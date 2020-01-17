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
/// Access via '.shared' static property.
/// Performs log in and log out actions as well as user related network calls.
final class CurrentUser {
    
    // MARK:- Properties
    
    static var shared = CurrentUser()
    
    private var conversationsListener: ListenerRegistration?
    
    private(set) var data: User?
    var isLoggedIn: Bool {
        return data != nil ? true : false
    }
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    
    /// Log in a new user with credentials.
    /// - Parameters:
    ///   - withEmail: Email address to log in to
    ///   - andPassword: Password to log in with
    ///   - completion: Completion handler
    public func logIn(withEmail: String, andPassword: String, completion: @escaping (_ error: Error?)->Void) {
        AuthenticationManager.shared.logIn(email: withEmail, password: andPassword) { user, error in
            if let error = error {
                completion(error)
            } else if let user = user {
                self.setCurrentUser(user)
                completion(nil)
            }
        }
    }
    
    /// Log out current user.
    /// - Parameter completion: Completion handler returning success truth value
    public func logOut(completion: @escaping (Bool)->Void) {
        self.nullifyUser()
        AuthenticationManager.shared.logOut { success in
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
        self.data?.isOnline = true
        self.data = newUser
    }
    
    /// Clear current user details when logged out.
    private func nullifyUser() {
        self.conversationsListener?.remove()
        self.data?.isOnline = false
        self.data = nil
    }
        
    /// Upates the database counterpart for the current user with any changes.
    /// - Parameter completion: Optional completion handler with empty default implementation
    public func updateUserDataInDb(completion: @escaping (()->Void) = {}) {
        guard let data = data else {return}
        UsersManager.shared.updateUserData(forUser: data) { (error)  in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }
    
    /// Adds a listener to the current user which listens for changes in existing conversations.
    /// - Parameter completion: Completion handler returning array of Conversation objects (often a single changed conversation)
    public func listenToConversations(completion: @escaping ([Conversation])->Void) {
        guard let data = data else {return}
        conversationsListener = UserMessagesManager.shared.listenToConversations(forUser: data) { (conversations) in
            completion(conversations)
        }
    }
    
}
