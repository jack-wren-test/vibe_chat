//
//  VideoMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 31/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

class VideoMessage: Message, ImageBasedMessage {
    
    // MARK:- Properties
    
    var videoUrl:           URL?
    var thumbnailImageUrl:  URL?
    var aspectRatio:        CGFloat
    
    // MARK:- Init
    
    init(videoUrl: URL, thumbnailImageUrl: URL, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        self.aspectRatio = aspectRatio
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        setType(type: .videoMessage)
        self.videoUrl = videoUrl
        self.thumbnailImageUrl = thumbnailImageUrl
        updateDictionaryRepresentation()
    }
    
    override init(withDictionary: [String: Any]) {
        if let videoUrlString = withDictionary["videoUrl"] as? String {
            self.videoUrl = URL(string: videoUrlString)
        }
        if let thumbnailImageUrlString = withDictionary["thumbnailImageUrl"] as? String {
            self.thumbnailImageUrl = URL(string: thumbnailImageUrlString)
        }
        if let aspectRatio = withDictionary["aspectRatio"] as? CGFloat {
            self.aspectRatio = aspectRatio
        } else {
            self.aspectRatio = CGFloat(16/9)
        }
        super.init(withDictionary: withDictionary)
        setType(type: .videoMessage)
        updateDictionaryRepresentation()
    }
    
    // MARK:- Methods
    
    private func updateDictionaryRepresentation() {
        if let videoUrl = self.videoUrl {
            dictionaryRepresentation["videoUrl"] = videoUrl.absoluteString
            
        }
        if let thumbnailImageUrl = self.thumbnailImageUrl {
            dictionaryRepresentation["thumbnailImageUrl"] = thumbnailImageUrl.absoluteString
            
        }
        dictionaryRepresentation["aspectRatio"] = aspectRatio
    }
    
}
