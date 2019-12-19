//
//  DatabaseClient.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import FirebaseFirestore

enum dbCollection: String {
    typealias RawValue = String
    case users, messaging, conversations, messages, groups, userMessages
}

class FirestoreManager {
    static let db = Firestore.firestore()
}
