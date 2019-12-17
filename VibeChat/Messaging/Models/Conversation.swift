//
//  MessageThread.swift
//  VibeChat
//
//  Created by Jack Smith on 17/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

// INCORPORATE MODEL

enum MessageThreadType: String {
    typealias RawValue = String
    case Private, Group
}

class Conversation {
    
    // MARK:- Properties
    
    var type:               String
    var lastMessageTime:    Date
    var threadUid:          String
    var userUids:           [String]
    var chatter:            User?
    var isReadStatus:       Bool {
        didSet {
            MessagesManager.shared.updateConversationStatus(threadUid: threadUid,
                                                      lastMessageTime: lastMessageTime,
                                                      isReadStatus: isReadStatus)
        }
    }
    
    // MARK:- Init
    
    init(withDictionary: [String: Any]) {
        type = withDictionary["type"] as! String
        isReadStatus = withDictionary["isReadStatus"] as! Bool
        lastMessageTime = (withDictionary["lastMessageTime"] as! Timestamp).dateValue()
        userUids = withDictionary["userUids"] as! [String]
        threadUid = withDictionary["threadUid"] as! String
        fetchChatter()
    }
    
    // MARK:- Methods
    
    fileprivate func fetchChatter() {
        let chatterUid = CurrentUser.shared.user?.uid == userUids[0] ? userUids[1] : userUids[0]
        UsersManager.shared.fetchUserData(uid: chatterUid) { (user) in
            if let user = user {
                self.chatter = user
            }
        }
    }
    
}
