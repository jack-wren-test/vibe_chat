//
//  ImageMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Procol to ensure any image based message has an aspect ratio property.
protocol ImageBasedMessage {
    var aspectRatio: CGFloat { get }
}

/// Model for an image message.
class ImageMessage: Message, ImageBasedMessage {
    
    // MARK:- Properties
    
    private(set) var imageUrl: URL?
    private(set) var aspectRatio: CGFloat
    
    // MARK:- Init
    
    init(imageUrl: URL, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, conversationId: String) {
        self.imageUrl = imageUrl
        self.aspectRatio = aspectRatio
        
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, conversationId: conversationId)
        self.setType(type: .imageMessage)
        self.updateDictionaryRepresentation()
    }
    
    override init(withDictionary: [String: Any]) {
        if let aspectRatio = withDictionary["aspectRatio"] as? CGFloat,
            let imageUrlString = withDictionary["imageUrl"] as? String {
            self.aspectRatio = aspectRatio
            self.imageUrl = URL(string: imageUrlString)
        } else {
            self.aspectRatio = CGFloat(1)
        }
        
        super.init(withDictionary: withDictionary)
        self.setType(type: .imageMessage)
        self.updateDictionaryRepresentation()
    }
    
    // MARK:- Methods
    
    private func updateDictionaryRepresentation() {
        guard let imageUrl = self.imageUrl else {return}
        self.dictionaryRepresentation["imageUrl"] = imageUrl.absoluteString
        self.dictionaryRepresentation["aspectRatio"] = self.aspectRatio
    }
    
    
}

