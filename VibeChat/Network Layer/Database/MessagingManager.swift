//
//  MessagesClient.swift
//  VibeChat
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import FirebaseFirestore

/// Class for managing queries to Firestore messages location.
final class MessagingManager: FirestoreManager {
    
    // MARK:- Properties
    
    static let shared = MessagingManager()
    
    private let collectionReference = FirestoreManager.db.collection(dbCollection.messaging.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    
    /// Upload a message to Firestore database.
    /// - Parameters:
    ///   - message: The message to be uploaded
    ///   - completion: Completion handler with empty default implementation
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
    
    
    /// Creates a listener for listening for new messages in a specified conversation.
    /// - Parameters:
    ///   - onConversation: The conversation to listen to
    ///   - completion: Completion handler returning optional array of Message objects
    /// - Returns:
    ///   - The listener registration object
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
    
    
    /// Parses an array of Firebase DocumentChange objects to array of Message objects.
    /// - Parameters:
    ///   - documentChange: The document change to parse
    ///   - completion: Completion handler returining array of optional Message objects
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
