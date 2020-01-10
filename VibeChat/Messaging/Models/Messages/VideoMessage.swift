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
class VideoMessage: ImageMessage {
    
    // MARK:- Properties
    
    var videoUrl: URL?
    
    // MARK:- Init
    
    init(videoUrl: URL, thumbnailImageUrl: URL, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        super.init(imageUrl: thumbnailImageUrl, aspectRatio: aspectRatio, toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        setType(type: .videoMessage)
        self.videoUrl = videoUrl
        updateDictionaryRepresentation()
    }
    
    override init(withDictionary: [String: Any]) {
        if let videoUrlString = withDictionary["videoUrl"] as? String {
            self.videoUrl = URL(string: videoUrlString)
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
    }
    
}
