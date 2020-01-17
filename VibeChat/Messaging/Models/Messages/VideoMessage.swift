//
//  VideoMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 31/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Model for a video message.
final class VideoMessage: ImageMessage {
    
    // MARK:- Properties
    
    private(set) var videoUrl: URL?
    
    // MARK:- Init
    
    init(videoUrl: URL, thumbnailImageUrl: URL, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, conversationId: String) {
        super.init(imageUrl: thumbnailImageUrl, aspectRatio: aspectRatio, toUid: toUid, fromUid: fromUid, timestamp: timestamp, conversationId: conversationId)
        self.setType(type: .videoMessage)
        self.videoUrl = videoUrl
        self.updateDictionaryRepresentation()
    }
    
    override init(withDictionary: [String: Any]) {
        if let videoUrlString = withDictionary["videoUrl"] as? String {
            self.videoUrl = URL(string: videoUrlString)
        }
        
        super.init(withDictionary: withDictionary)
        self.setType(type: .videoMessage)
        self.updateDictionaryRepresentation()
    }
    
    // MARK:- Methods
    
    private func updateDictionaryRepresentation() {
        guard let videoUrl = self.videoUrl else {return}
        self.dictionaryRepresentation["videoUrl"] = videoUrl.absoluteString
    }
    
}
