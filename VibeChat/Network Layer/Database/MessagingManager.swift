//
//  MessagesClient.swift
//  VibeChat
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import FirebaseFirestore

final class MessagingManager: FirestoreManager {
    
    // MARK:- Singleton Setup
    
    static let shared = MessagingManager()
    private let collectionReference = FirestoreManager.db.collection(dbCollection.messaging.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    public func uploadMessage(message: Message, completion: @escaping ()->()) {
        collectionReference.document(message.conversationId).collection(dbCollection.messages.rawValue).addDocument(data: message.toDict()) { (error) in
            if let error = error {
                print("Error uploading message: \(error.localizedDescription)")
                completion()
                return
            }
            completion()
        }
    }
    
    public func listenForMessages(onConversation: Conversation, completion: @escaping ([Message]?)->()) {
        let conversationId = onConversation.uid
        collectionReference.document(conversationId).collection(dbCollection.messages.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error retrieving snapshot: \(error.localizedDescription)")
                completion(nil)
            }
            if let snapshot = snapshot?.documentChanges {
                self.snapshotDocumentsToMessageArray(snapshot, completion: completion)
            }
        }
    }
    
    public func createConversationInMessaging(conversationData: [String: Any], completion: @escaping ()->()) {
        collectionReference.document(conversationData["uid"] as! String).collection(dbCollection.messages.rawValue)
    }
    
    // CHANGE THIS TO GENERIC DATA ARRAY FOR USE WITH USERS TOO? THEN COULD PUT IN DATABASEMANAGERCLASS
    fileprivate func snapshotDocumentsToMessageArray(_ documentChange: [DocumentChange], completion: @escaping ([Message]?)->()) {
        var messages = [Message]()
        documentChange.forEach { (document) in
            let messageData = document.document.data()
            let message = Message(withDictionary: messageData)
            messages.append(message)
        }
        DispatchQueue.main.async {
            completion(messages)
        }
    }
    
}
