//
//  MessageThread.swift
//  VibeChat
//
//  Created by Jack Smith on 17/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Enummeration for conversation types.
enum ConversationType: String {
    typealias RawValue = String
    case Private, Group
}

/// Model for a conversation between two or more users.
class Conversation {
    
    // MARK:- Properties
    
    var hasDbCounterpart:   Bool = false
    var type:               String
    var lastMessageTime:    Date
    var uid:                String
    var userUids:           [String]
    var userNames:          [String]
    var chatter:            User?
    var chatterListener:    ListenerRegistration?
    var isReadStatus:       Bool {
        didSet {
            if hasDbCounterpart {
                UserMessagesManager.shared.updateConversationStatusForCurrentUser(conversation: self,
                                                                                  toIsRead: isReadStatus,
                                                                                  withNewMessageTime: lastMessageTime)
            }
        }
    }
    
    // MARK:- Lifecycle
    
    /// Init from chatter details. For use when a conversation is created with the application.
    /// - Parameter withChatter: The chatter to create a conversation with
    init(withChatter: User) {
        type = "private"
        lastMessageTime = Date()
        uid = CurrentUser.shared.data!.uid+"_"+withChatter.uid
        userUids = [CurrentUser.shared.data!.uid, withChatter.uid]
        userNames = [CurrentUser.shared.data!.name, withChatter.name]
        chatter = withChatter
        isReadStatus = false
    }
    
    /// Init from [String: Any] Dictionary. For use when creating a conversation from Firestore data.
    /// - Parameter withDictionary: The dictionary to create a conversation from
    init(withDictionary: [String: Any]) {
        type = withDictionary["type"] as! String
        isReadStatus = withDictionary["isReadStatus"] as! Bool
        lastMessageTime = (withDictionary["lastMessageTime"] as! Timestamp).dateValue()
        userUids = withDictionary["userUids"] as! [String]
        userNames = withDictionary["userNames"] as! [String]
        uid = withDictionary["uid"] as! String
        hasDbCounterpart = true
    }
    
    deinit {
        print("Conversation deinitialized")
        chatterListener?.remove()
    }
    
    // MARK:- Methods
    
    /// Returns a Dictionary representation of the Conversation
    public func toDict() -> [String: Any] {
        let data: [String: Any] = ["userNames": [CurrentUser.shared.data?.name, chatter?.name],
                                   "userUids": [CurrentUser.shared.data?.uid, chatter?.uid],
                                   "type": "private",
                                   "isReadStatus": false,
                                   "lastMessageTime": Timestamp(date: Date()),
                                   "uid": uid]
        return data
    }
    
    /// Fetches the chatter associated with the conversation.
    /// - Parameter completion: Completion handler passing a success truth value
    public func fetchChatter(completion: @escaping (_ success: Bool)->()) {
        let chatterUid = CurrentUser.shared.data?.uid == userUids[0] ? userUids[1] : userUids[0]
        UsersManager.shared.fetchUserData(uid: chatterUid) { (user) in
            if let user = user {
                self.chatter = user
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Creates a listener to listen to changes for the chatter associated with the conversation.
    /// - Parameter completion: Completion handler with a default empty implementation
    public func listenToChatter(completion: @escaping ()->Void = {}) {
        if let chatter = chatter {
            self.chatterListener = UsersManager.shared.listenToUserData(user: chatter) { (user) in
                self.chatter = user
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}
