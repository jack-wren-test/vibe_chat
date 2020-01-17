//
//  TextMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import Foundation

/// Model for a text based message.
final class TextMessage: Message {
    
    // MARK:- Properties
    
    private(set) var text:   String?
    
    // MARK:- Init
    
    init(text: String, toUid: String, fromUid: String, timestamp: Date, conversationId: String) {
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, conversationId: conversationId)
        self.setType(type: .textMessage)
        self.text = text
        self.updateDictionaryRepresentation()
    }
    
    override init(withDictionary: [String: Any]) {
        super.init(withDictionary: withDictionary)
        self.setType(type: .textMessage)
        if let text = withDictionary["text"] as? String {
            self.text = text
        }
        self.updateDictionaryRepresentation()
    }
    
    // MARK:- Methods
    
    private func updateDictionaryRepresentation() {
        guard let text = self.text else {return}
        self.dictionaryRepresentation["text"] = text
    }
    
}
