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
class GiphyMessage: Message, ImageBasedMessage {
    
    // MARK:- Properties
    
    var giphId: String?
    var aspectRatio: CGFloat
    
    // MARK:- Init
    
    init(giphId: String, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        self.giphId = giphId
        self.aspectRatio = aspectRatio
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        setType(type: .giphyMessage)
        updateDictionaryRepresentation()
    }
    
    override init(withDictionary: [String : Any]) {
        giphId = withDictionary["giphId"] as? String
        if let aspectRatio = withDictionary["aspectRatio"] as? CGFloat {
            self.aspectRatio = aspectRatio
        } else {
            self.aspectRatio = CGFloat(16/9)
        }
        super.init(withDictionary: withDictionary)
        setType(type: .giphyMessage)
        updateDictionaryRepresentation()
    }
    
    // MARK:- Methods
    
    private func updateDictionaryRepresentation() {
        if let giphId = self.giphId {
            dictionaryRepresentation["giphId"] = giphId
        }
        dictionaryRepresentation["aspectRatio"] = aspectRatio
    }
    
}
