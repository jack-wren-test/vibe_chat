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
    
    public func uploadMessage(message: Message, completion: @escaping ()->() = {}) {
        guard let conversationId = message.conversationId else {return}
        collectionReference.document(conversationId).collection(dbCollection.messages.rawValue).addDocument(data: message.dictionaryRepresentation) { (error) in
            if let error = error {
                print("Error uploading message: \(error.localizedDescription)")
                completion()
                return
            }
            completion()
        }
    }
    
    public func listenForMessages(onConversation: Conversation, completion: @escaping ([Message]?)->()) -> ListenerRegistration {
        let conversationId = onConversation.uid
        let listener = collectionReference.document(conversationId).collection(dbCollection.messages.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error retrieving snapshot: \(error.localizedDescription)")
                completion(nil)
            }
            DispatchQueue.main.async {
                if let snapshot = snapshot?.documentChanges {
                    self.snapshotDocumentsToMessageArray(snapshot, completion: completion)
                }
            }
        }
        return listener
    }
    
    public func createConversationInMessaging(conversationData: [String: Any], completion: @escaping ()->()) {
        collectionReference.document(conversationData["uid"] as! String).collection(dbCollection.messages.rawValue)
    }
    
    fileprivate func snapshotDocumentsToMessageArray(_ documentChange: [DocumentChange], completion: @escaping ([Message]?)->()) {
        var messages = [Message]()
        documentChange.forEach { (document) in
            let messageData = document.document.data()
            if messageData["videoUrl"] != nil {
                let videoMessage = VideoMessage(withDictionary: messageData)
                messages.append(videoMessage)
            } else if messageData["imageUrl"] != nil {
                let imageMessage = ImageMessage(withDictionary: messageData)
                messages.append(imageMessage)
            } else if messageData["giphId"] != nil {
                let giphyMessage = GiphyMessage(withDictionary: messageData)
                messages.append(giphyMessage)
            } else {
                let message = TextMessage(withDictionary: messageData)
                messages.append(message)
            }
        }
        completion(messages)
    }
    
}
