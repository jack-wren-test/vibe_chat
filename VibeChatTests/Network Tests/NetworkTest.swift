//
//  NetworkTest.swift
//  VibeChatTests
//
//  Created by Jack Smith on 14/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import XCTest
@testable import VibeChat

class NetworkTest: XCTestCase {
    
    // MARK:- Methods

    static func createTestAccount(testUser: User, password: String) {
        let semaphore = DispatchSemaphore(value: 0)
        AuthenticationManager.shared.authenticateNewAccout(withEmail: testUser.email,
                                                           password: password) { (_,_)  in
            UsersManager.shared.updateUserData(forUser: testUser) { (error) in
                if error != nil {
                    print("Published user data.")
                    semaphore.signal()
                }
            }
        }
        let _ = semaphore.wait(timeout: .now() + 10.0)
    }
    
    static func deleteTestAccount(testUser: User) {
        let queue = DispatchQueue(label: "com.deleteTestAccount.queue")
        let semaphore = DispatchSemaphore(value: 0)
        queue.sync {
            AuthenticationManager.shared.deleteAccount() { (_) in
                semaphore.signal()
            }
        }
        let _ = semaphore.wait(timeout: .now() + 5.0)
    }
    
    static func deleteTestData(testUser: User) {
        FirestoreManager.db.collection("users").document(testUser.uid).delete()
    }

}
