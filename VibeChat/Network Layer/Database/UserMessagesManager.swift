//
//  ConversationsManager.swift
//  VibeChat
//
//  Created by Jack Smith on 18/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Firebase

final class UserMessagesManager {
    
    // MARK:- Singleton Setup
    
    static let shared = UserMessagesManager()
    private let collectionReference = FirestoreManager.db.collection(dbCollection.userMessages.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    public func createConversationIfNeeded(conversation: Conversation, completion: @escaping (_ conversation: Conversation?)->()) {
        
        guard let uid = CurrentUser.shared.user?.uid else {return}
        guard let chatter = conversation.chatter else {return}
        var foundMatch: Bool = false
        let potentialConversationIds = [uid+"_"+chatter.uid, chatter.uid+"_"+uid]
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking for message threads: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let ConversationIds = snapshot?.documents else {completion(nil); return}
            ConversationIds.forEach { (conversationId) in
                potentialConversationIds.forEach { (potentialConversationId) in
                    if conversationId.documentID == potentialConversationId && foundMatch == false {
                        completion(nil)
                        foundMatch = !foundMatch
                    }
                }
            }
            if !foundMatch {
                self.createConversation(conversation: conversation, andChatterName: chatter.name) { (conversation) in
                    if let conversation = conversation {
                        completion(conversation)
                    }
                }
            }
        }
    }
    
    fileprivate func createConversation(conversation: Conversation, andChatterName: String, completion: @escaping (_ conversation: Conversation?)->()) {
        print("Create conversation called...")
        let group = DispatchGroup()
        group.enter()
        group.enter()
        publishConversation(conversation.userUids[0], conversation.uid, conversation.toDict()) { (success) in
            if success {
                print("Pulished conversation for: \(conversation.userUids[0])")
            }
            group.leave()
        }
        publishConversation(conversation.userUids[1], conversation.uid, conversation.toDict()) { (success) in
            if success {
                print("Pulished conversation for: \(conversation.userUids[1])")
            }
            group.leave()
        }
        DispatchQueue.main.async {
            completion(conversation)
        }
    }
    
    // MIGHT NOT BE NESSESARY
    public func listenForConversationChanges(conversaion: Conversation, completion: @escaping (Conversation?)->()) {
        guard let uid = CurrentUser.shared.user?.uid else {return}
        let conversationId = conversaion.uid
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(conversationId).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error adding listener to thread: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let snapshotData = snapshot?.data() {
                let thread = Conversation(withDictionary: snapshotData)
                completion(thread)
            }
        }
    }
    
    public func listenToConversationsForCurrentUser(completion: @escaping ([Conversation]?)->()) {
        guard let uid = CurrentUser.shared.user?.uid else {return}
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error adding listener to user conversations: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let documentChanges = snapshot?.documentChanges {
                var conversations = [Conversation]()
                for documentChange in documentChanges {
                    let data = documentChange.document.data()
                    let conversation = Conversation(withDictionary: data)
                    print("Trying to add conversation: \(conversation.uid)")
                    conversations.append(conversation)
                }
                completion(conversations)
            }
        }
    }
    
    public func toggleChatterIsOnline(conversation: Conversation) {
        print("Toggle chatter is online called")
        guard let uid = CurrentUser.shared.user?.uid else {return}
        let chatterUid = uid == conversation.userUids[0] ? conversation.userUids[1] : conversation.userUids[0]
        let data: [String: Any] = ["chatterIsOnline": conversation.chatterIsOnline!]
    collectionReference.document(chatterUid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true)
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true)
    }
    
    public func updateConversationStatus(conversation: Conversation, userIsRead: Bool, chatterIsRead: Bool, withNewMessageTime: Date?, completion: @escaping ()->()) {
        print("Update conversation status called")
        guard let uid = CurrentUser.shared.user?.uid else {return}
        let chatterUid = uid == conversation.userUids[0] ? conversation.userUids[1] : conversation.userUids[0]

        var data: [String: Any] = ["isReadStatus": userIsRead]
        if let lastMessageTime = withNewMessageTime {
            data["lastMessageTime"] = Timestamp(date: lastMessageTime)
        }

        let group = DispatchGroup()
        group.enter()
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true) { (error) in
            if let error = error {print("Error uploading message: \(error.localizedDescription)"); return}
            group.leave()
        }

        data["isReadStatus"] = chatterIsRead
        group.enter()
        collectionReference.document(chatterUid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true) { (error) in
            if let error = error {print("Error uploading message: \(error.localizedDescription)"); return}
            group.leave()
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    public func updateConversationStatusForChatter(conversation: Conversation, toIsRead: Bool, withNewMessageTime: Date?) {
        print("Update conversation status for chatter called...")
        guard let uid = CurrentUser.shared.user?.uid else {return}
        let chatterUid = uid == conversation.userUids[0] ? conversation.userUids[1] : conversation.userUids[0]
        updateConversationStatus(conversation, toIsRead, withNewMessageTime, chatterUid)
    }

//    public func updateConversationStatusForCurrentUser(conversation: Conversation, toIsRead: Bool, withNewMessageTime: Date?) {
//        print("Update conversation status for current user called...")
//        guard let uid = CurrentUser.shared.user?.uid else {return}
//        updateConversationStatus(conversation, toIsRead, withNewMessageTime, uid)
//    }

    fileprivate func updateConversationStatus(_ conversation: Conversation, _ toIsRead: Bool, _ withNewMessageTime: Date?, _ forUid: String) {
        print("Update conversation status 2 called...")
        var data: [String: Any] = ["isReadStatus": toIsRead]
        if let lastMessageTime = withNewMessageTime {
            data["lastMessageTime"] = Timestamp(date: lastMessageTime)
        }
        collectionReference.document(forUid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true)
    }
    
    fileprivate func publishConversation(_ forUserId: String, _ withConversationId: String, _ data: [String : Any], _ completion: @escaping (_ success: Bool) -> ()) {
    collectionReference.document(forUserId).collection(dbCollection.conversations.rawValue).document(withConversationId).setData(data) { (error) in
            if let error = error {
                print("Error creating message thread: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
}
