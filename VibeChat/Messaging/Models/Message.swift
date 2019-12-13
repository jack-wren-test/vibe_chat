//
//  Message.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    // MARK:- Properties
    
    var text:       String
    var toUid:      String
    var fromUid:    String
    var timestamp:  Date
    var type:       String
    var threadId:   String
    
    // MARK:- Initializers
    
    // For testing
    init(text: String, toUid: String, fromUid: String, timestamp: Date, type: String, threadId: String) {
        self.text = text
        self.toUid = toUid
        self.fromUid = fromUid
        self.timestamp = timestamp
        self.type = type
        self.threadId = threadId
    }
    
    init(withDictionary: [String: Any]) {
        text = withDictionary["text"] as! String
        toUid = withDictionary["toUid"] as! String
        fromUid = withDictionary["fromUid"] as! String
        type = withDictionary["type"] as! String
        threadId = withDictionary["threadId"] as! String
        timestamp = (withDictionary["timestamp"] as! Timestamp).dateValue()
    }
    
    // MARK:- Methods
    
    public func toDict() -> [String: Any] {
        let tStamp = Timestamp.init(date: timestamp)
        let dict: [String: Any] = ["text": text,
                                   "toUid": toUid,
                                   "fromUid": fromUid,
                                   "type": type,
                                   "threadId": threadId,
                                   "timestamp": tStamp]
        return dict
    }
}
