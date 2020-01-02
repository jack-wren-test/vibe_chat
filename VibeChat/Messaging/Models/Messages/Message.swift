//
//  Message.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

// TODO:- Break out text message into subclass

class Message: NSObject {
    
    // MARK:- Properties
    
    var text:           String?
    var toUid:          String?
    var fromUid:        String?
    var timestamp:      Date?
    var conversationId: String?
    
    // MARK:- Initializers
    
    init(text: String?, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        self.text = text
        self.toUid = toUid
        self.fromUid = fromUid
        self.timestamp = timestamp
        self.conversationId = threadId
    }
    
    init(withDictionary: [String: Any]) {
        text = withDictionary["text"] as? String
        toUid = withDictionary["toUid"] as? String
        fromUid = withDictionary["fromUid"] as? String
        conversationId = withDictionary["threadId"] as? String
        if let timestamp = withDictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        }
    }
    
    // MARK:- Methods
    
    public func toDict() -> [String: Any] {
        let tStamp = Timestamp.init(date: timestamp ?? Date())
        let dict: [String: Any] = ["text": text ?? "",
                                   "toUid": toUid ?? "",
                                   "fromUid": fromUid ?? "",
                                   "threadId": conversationId ?? "",
                                   "timestamp": tStamp]
        return dict
    }
}