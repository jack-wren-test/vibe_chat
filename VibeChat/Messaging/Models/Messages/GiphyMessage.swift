//
//  giphyMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Model for a gif baed message.
final class GiphyMessage: Message, ImageBasedMessage {
    
    // MARK:- Properties
    
    private(set) var giphId: String
    private(set) var aspectRatio: CGFloat
    
    // MARK:- Init
    
    init(giphId: String, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, conversationId: String) {
        self.giphId = giphId
        self.aspectRatio = aspectRatio
        
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, conversationId: conversationId)
        self.setType(type: .giphyMessage)
        self.updateDictionaryRepresentation()
    }
    
    override init(withDictionary: [String : Any]) {
        self.giphId = withDictionary["giphId"] as! String
        if let aspectRatio = withDictionary["aspectRatio"] as? CGFloat {
            self.aspectRatio = aspectRatio
        } else {
            self.aspectRatio = CGFloat(1)
        }
        
        super.init(withDictionary: withDictionary)
        self.setType(type: .giphyMessage)
        self.updateDictionaryRepresentation()
    }
    
    // MARK:- Methods
    
    private func updateDictionaryRepresentation() {
        self.dictionaryRepresentation["giphId"] = self.giphId
        self.dictionaryRepresentation["aspectRatio"] = self.aspectRatio
    }
    
}
