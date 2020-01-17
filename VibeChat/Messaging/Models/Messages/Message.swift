//
//  Message.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Enummeration for message types.
enum MessageType {
    
    case textMessage, videoMessage, imageMessage, giphyMessage
    
    var reuseId: String {
        switch self {
        case .textMessage:
            return "textMessageCell"
        case .videoMessage:
            return "imageMessageCell"
        case .imageMessage:
            return "videoMessageCell"
        case .giphyMessage:
            return "giphyMessageCell"
        }
    }
    
}

/// Base model for a message.
class Message {
    
    // MARK:- Properties b
    
    var dictionaryRepresentation: [String: Any]!
    private(set) var type: MessageType?
    private(set) var toUid: String?
    private(set) var fromUid: String?
    private(set) var timestamp: Date?
    private(set) var conversationId: String?
    
    // MARK:- Init
    
    init(toUid: String, fromUid: String, timestamp: Date, conversationId: String) {
        self.toUid = toUid
        self.fromUid = fromUid
        self.timestamp = timestamp
        self.conversationId = conversationId
        self.dictionaryRepresentation = self.toDict()
    }
    
    init(withDictionary: [String: Any]) {
        self.toUid = withDictionary["toUid"] as? String
        self.fromUid = withDictionary["fromUid"] as? String
        self.conversationId = withDictionary["threadId"] as? String
        if let timestamp = withDictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        }
        self.dictionaryRepresentation = self.toDict()
    }
    
    // MARK:- Methods
    
    public func setType(type: MessageType) {
        self.type = type
    }
    
    private func toDict() -> [String: Any] {
        let tStamp = Timestamp.init(date: self.timestamp ?? Date())
        let dict: [String: Any] = ["toUid": self.toUid ?? "",
                                   "fromUid": self.fromUid ?? "",
                                   "threadId": self.conversationId ?? "",
                                   "timestamp": tStamp]
        return dict
    }
    
}
