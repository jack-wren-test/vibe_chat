//
//  DatabaseClient.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import FirebaseFirestore

/// Enumeration for Firestore database locations.
enum dbCollection: String {
    typealias RawValue = String
    case users, messaging, conversations, messages, groups, userMessages
}

/// Base class for Firestore database managers.
class FirestoreManager {
    static let db = Firestore.firestore()
}
