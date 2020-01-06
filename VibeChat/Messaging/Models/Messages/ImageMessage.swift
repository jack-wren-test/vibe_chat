//
//  ImageMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

protocol ImageBasedMessage {
    var aspectRatio: CGFloat { get }
}

class ImageMessage: Message, ImageBasedMessage {
    
    // MARK:- Properties
    
    var imageUrl: URL?
    var aspectRatio: CGFloat
    
    // MARK:- Init
    
    init(imageUrl: URL, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        self.imageUrl = imageUrl
        self.aspectRatio = aspectRatio
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        setType(type: .imageMessage)
        updateDictionaryRepresentation()
    }
    
    override init(withDictionary: [String: Any]) {
        if let aspectRatio = withDictionary["AspectRatio"] as? CGFloat {
            self.aspectRatio = aspectRatio
        } else {
            self.aspectRatio = CGFloat(16/9)
        }
        if let imageUrlString = withDictionary["imageUrl"] as? String {
            self.imageUrl = URL(string: imageUrlString)
        }
        super.init(withDictionary: withDictionary)
        setType(type: .imageMessage)
        updateDictionaryRepresentation()
    }
    
    // MARK:- Handlers
    
    private func updateDictionaryRepresentation() {
        if let imageUrl = self.imageUrl {
            dictionaryRepresentation["imageUrl"] = imageUrl.absoluteString
        }
        dictionaryRepresentation["aspectRatio"] = aspectRatio
    }
    
    
}

