//
//  Authentication.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import FirebaseAuth

/// Class for managing Firebase authentication tasks.
final class AuthenticationManager {
    
    // MARK:- Properties
    
    static let shared = AuthenticationManager()
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    /// Create an account in the Firebase backend system using credentials.
    /// Logs in, and sets the current user if successful.
    /// - Parameters:
    ///   - name: Display name
    ///   - email: Email address
    ///   - password: Password
    ///   - completion: Completion handler passing success truth value
    public func createAccount(name: String, email: String, password: String, completion: @escaping (Bool)->()) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let uid = result?.user.uid else {return}
            let user = User(uid: uid, name: name, email: email)
            CurrentUser.shared.setCurrentUser(user)
            UsersManager.shared.updateUserData(forUser: user) { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    /// Log user in to firebase backend system using credentials, allowing access to database and storage systems.
    /// - Parameters:
    ///   - email: Email address
    ///   - password: Password
    ///   - completion: Completion handler passing optional User object
    public func logIn(email: String, password: String, completion: @escaping (User?)->()) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                completion(nil)
            }
            if let uid = result?.user.uid {
                UsersManager.shared.fetchUserData(uid: uid) { (user) in
                    user?.isOnline = true
                    completion(user)
                }
            }
        }
    }
    
    /// Log out current user from Firebase backend system.
    /// - Parameter completion: Completion passing returning success truth value
    public func logOut(completion: @escaping (Bool)->()) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            print("Error logging out user: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    /// Check to see if the previous user of this app & device is valid and already logged in to Firebase backend system.
    /// - Parameter completion: Completion handler passing optional User object
    public func checkForValidUser(completion: @escaping (_ user: User?)->()) {
        if let uid = Auth.auth().currentUser?.uid {
            UsersManager.shared.fetchUserData(uid: uid) { (user) in
                if let user = user {
                    user.isOnline = true
                    DispatchQueue.main.async {
                        completion(user)
                    }
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    
}
