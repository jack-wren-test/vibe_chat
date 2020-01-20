//
//  MediaMessageUploader.swift
//  VibeChat
//
//  Created by Jack Smith on 16/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import Firebase
import GiphyCoreSDK

/// Enum for each type of media that can be uploaded.
enum MediaType {
    case image, video, gif
}

/// Class for uploading all media messages.
class MediaMessageUploader {
    
    // MARK:- Properties
    
    var type: MediaType
    
    private(set) var conversation: Conversation
    private(set) var isFirstMessage: Bool
    private var image: UIImage?
    private var video: Data?
    private var gif: GPHMedia?
    private var videoFileUrl: URL?
    
    // MARK:- Lifecycle
    
    /// Initialiser for an image uploader.
    /// - Parameters:
    ///   - image: The image to upload
    ///   - conversation: The conversation to upload to
    ///   - isFirstMessage: Boolean stating if this is the first message
    init(image: UIImage, conversation: Conversation, isFirstMessage: Bool) {
        self.image = image
        self.type = .image
        self.conversation = conversation
        self.isFirstMessage = isFirstMessage
    }
    
    /// Initialiser for a video uploader.
    /// - Parameters:
    ///   - video: The video to upload
    ///   - videoFileUrl: The url of the local video file
    ///   - conversation: The conversation to upload to
    ///   - isFirstMessage: Boolean stating if this is the first message
    init(video: Data, videoFileUrl: URL, conversation: Conversation, isFirstMessage: Bool) {
        self.video = video
        self.videoFileUrl = videoFileUrl
        self.type = .video
        self.conversation = conversation
        self.isFirstMessage = isFirstMessage
    }
    
    /// Initialiser for a gif uploader.
    /// - Parameters:
    ///   - gif: The gif to upload
    ///   - conversation: The conversation to upload to
    ///   - isFirstMessage: Boolean stating if this is the first message
    init(gif: GPHMedia, conversation: Conversation, isFirstMessage: Bool) {
        self.gif = gif
        self.type = .gif
        self.conversation = conversation
        self.isFirstMessage = isFirstMessage
    }
    
    deinit {
        print("Media message uploader deinitialized.")
    }
    
    // MARK:- Methods
    
    /// Upload the media message.
    /// - Parameter completion: Completion handler passing a success truth value.
    public func uploadMessage(completion: @escaping (_ success: Bool)->Void) -> StorageUploadTask? {
        var uploadTask: StorageUploadTask? = nil
        switch type {
        case .image:
            uploadTask = uploadImage(completion: completion)
        case .video:
            uploadTask = uploadVideo(completion: completion)
        case .gif:
            uploadGif(completion: completion)
        }
        return uploadTask
    }
    
    /// Upload a gif reference to the Firestore database.
    /// - Parameter completion: Completion handler passing a success truth value.
    private func uploadGif(completion: @escaping (_ success: Bool)->Void) {
        guard let gif = self.gif else {return}
        checkForConversationAndSendGiphyMessage(onConversation: conversation,
                                                withGiphId: gif.id,
                                                andAspectRatio: gif.aspectRatio,
                                                completion: completion)
    }
    
    /// Upload an image to storage and link video message to Url.
    /// - Parameter completion: Completion handler passing a success truth value.
    private func uploadImage(completion: @escaping (_ success: Bool)->Void) -> StorageUploadTask? {
        guard let image = image else {return nil}
        let aspectRatio = image.size.width / image.size.height
        let uploadTask = self.uploadImageMessage(image: image,
                                                 onConversation: self.conversation,
                                                 aspectRatio: aspectRatio,
                                                 completion: completion)
        return uploadTask
    }
    
    /// Upload a video to storage and link video message to Url.
    /// - Parameter completion: Completion handler passing a success truth value.
    private func uploadVideo(completion: @escaping (_ success: Bool)->Void) -> StorageUploadTask? {
        guard let video = self.video, let videoFileUrl = self.videoFileUrl else {return nil}
        let uploadTask = self.uploadVideoMessage(onConversation: self.conversation,
                                                 videoData: video,
                                                 videoFileUrl: videoFileUrl,
                                                 completion: completion)
        return uploadTask
    }
    
}
