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
    
    /// Create an account in the Firebase backend system using credentials. Performs authentication, sets initial user data and logs in user to app.
    /// Performs authentication, sets initial user data and logs in user to app if successfull.
    /// - Parameters:
    ///   - name: Display name
    ///   - email: Email address
    ///   - password: Password
    ///   - completion: Completion handler passing success truth value
    public func createVibeChatAccount(name: String,
                                      email: String,
                                      password: String,
                                      completion: @escaping (_ error: Error?)->Void) {
        authenticateNewAccout(withEmail: email, password: password) { [weak self] uid, error  in
            guard let self = self else {return}
            if let error = error {
                completion(error)
                return
            }
            guard let uid = uid else {return}
            let user = User(uid: uid, name: name, email: email)
            self.updateCurrentUser(user, completion: completion)
        }
    }
    
    /// Authenticates a new user.
    /// - Parameters:
    ///   - withEmail: The email to authenticate with
    ///   - password: Password associated with account
    ///   - completion: Completion handler passing optional string containing the user uid
    public func authenticateNewAccout(withEmail: String,
                                      password: String,
                                      completion: @escaping (_ uid: String?, _ error: Error?)->Void) {
        Auth.auth().createUser(withEmail: withEmail, password: password) { result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let uid = result?.user.uid else {return}
            completion(uid, nil)
        }
    }
    
    /// Log user in to firebase backend system using credentials, allowing access to database and storage systems.
    /// - Parameters:
    ///   - email: Email address
    ///   - password: Password
    ///   - completion: Completion handler passing optional User object
    public func logIn(email: String,
                      password: String,
                      completion: @escaping (_ user: User?, _ error: Error?)->Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let uid = result?.user.uid  else {return}
            UsersManager.shared.fetchUserData(uid: uid) { (user) in
                user?.isOnline = true
                completion(user, nil)
            }
        }
    }
    
    /// Log out current user from Firebase backend system.
    /// - Parameter completion: Completion handler passing returning success truth value
    public func logOut(completion: @escaping (Bool)->Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            print("Error logging out user: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    /// Deletes the currently logged in user from Firebase authentication section
    /// - Parameter completion: Completion handler passing returning success truth value
    public func deleteAccount(completion: @escaping ((Bool)->Void) = {_ in}) {
        guard let user = Auth.auth().currentUser else {return}
        user.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                completion(false)
                return
            }
            UsersManager.shared.deleteUserData(forUid: user.uid)
            completion(true)
        }
    }
    
    /// Check to see if the previous user of this app & device is valid and already logged in to Firebase backend system.
    /// - Parameter completion: Completion handler passing optional User object
    public func checkForValidUser(completion: @escaping (_ user: User?)->Void) {
        guard let uid = Auth.auth().currentUser?.uid else {completion(nil); return}
        UsersManager.shared.fetchUserData(uid: uid) { user in
            guard let user = user else {completion(nil); return}
            user.isOnline = true
            DispatchQueue.main.async {
                completion(user)
            }
        }
    }
    
    private func updateCurrentUser(_ user: User, completion: @escaping (_ error: Error?)->Void) {
        CurrentUser.shared.setCurrentUser(user)
        UsersManager.shared.updateUserData(forUser: user) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    
}
