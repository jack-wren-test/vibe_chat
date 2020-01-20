//
//  MediaMessageUploader+Video.swift
//  VibeChat
//
//  Created by Jack Smith on 16/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Firebase

extension MediaMessageUploader {
    
    /// Upload video to storage and send video message.
    /// - Parameters:
    ///   - onConversation: The conversation to send the message to
    ///   - videoData: The video data to upload
    ///   - videoFileUrl: The Url for the video file
    ///   - completion: Completion handler passing a success truth value
    public func uploadVideoMessage(onConversation: Conversation,
                                   videoData: Data,
                                   videoFileUrl: URL,
                                   completion: @escaping (_ success: Bool)->Void) -> StorageUploadTask? {
        
        let uploadTask = StorageManager.shared.uploadVideoMessage(video: videoData) { uploadedVideoUrl in
            guard let uploadedVideoUrl = uploadedVideoUrl else {return}
            guard let thumbnailImage = self.thumbnailImageForVideoUrl(videoFileUrl: videoFileUrl) else {return}
            StorageManager.shared.uploadVideoThumbnail(image: thumbnailImage) { url in
                guard let thumbnailImageUrl = url else {return}
                let aspectRatio = thumbnailImage.size.width / thumbnailImage.size.height
                    self.checkForConversationAndSendVideoMessage(onConversation: onConversation,
                                                                 videoUrl: uploadedVideoUrl,
                                                                 thumbnailUrl: thumbnailImageUrl,
                                                                 aspectRatio: aspectRatio,
                                                                 completion: completion)
                }
        }
        return uploadTask
    }
    
    /// Get a thumbnail image from a video file Url.
    /// - Parameter videoFileUrl: The Url for the video file
    private func thumbnailImageForVideoUrl(videoFileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoFileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            print("Error getting thumbnail image: \(error.localizedDescription)")
        }
        return nil
    }
    
    /// Check for existing conversation in db (create one if it doesn't exist), and send video message.
    /// - Parameters:
    ///   - conversation: The conversation to send the message to
    ///   - videoUrl: The Url for the video file
    ///   - thumbnailUrl: Thumbnail image db Url
    ///   - aspectRatio: Thumbnail image aspect ratio
    ///   - completion: Completion handler passing a success truth value
    private func checkForConversationAndSendVideoMessage(onConversation conversation: Conversation,
                                                         videoUrl: URL,
                                                         thumbnailUrl: URL,
                                                         aspectRatio: CGFloat,
                                                         completion: @escaping (_ success: Bool)->Void) {
        guard let currentUser = CurrentUser.shared.data else {return}
        var semaphore: DispatchSemaphore?
        var semaphoreResult: DispatchTimeoutResult?
        if isFirstMessage {
            semaphore = DispatchSemaphore(value: 0)
            UserMessagesManager.shared.createConversation(conversation: conversation) { success in
                if success {
                    semaphore?.signal()
                }
            }
            guard let semaphore = semaphore else {return}
            semaphoreResult = semaphore.wait(timeout: .now() + 5.0)
        }
        if semaphore == nil || semaphoreResult == .success {
            self.sendVideoMessage(videoUrl: videoUrl, thumbnailUrl: thumbnailUrl, aspectRatio: aspectRatio,
            conversation: conversation, currentUser: currentUser, completion: completion)
        }
    }
    
    /// Send a video message.
    /// - Parameters:
    ///   - videoUrl: The db Url for the video
    ///   - thumbnailUrl: The db Url for the thumbnail image
    ///   - aspectRatio: The aspect ratio for the thumbnail
    ///   - conversation: The conversation to send the message to
    ///   - currentUser: The currently logged in user 
    ///   - completion: Completion handler passing a success truth value
    private func sendVideoMessage(videoUrl: URL,
                                  thumbnailUrl: URL,
                                  aspectRatio: CGFloat,
                                  conversation: Conversation,
                                  currentUser: User,
                                  completion: @escaping (_ success: Bool)->Void) {
        
        let message = VideoMessage(videoUrl: videoUrl,
                                   thumbnailImageUrl: thumbnailUrl,
                                   aspectRatio: aspectRatio,
                                   toUid: conversation.chatter!.uid,
                                   fromUid: currentUser.uid,
                                   timestamp: Date(),
                                   conversationId: conversation.uid)
        
        UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
            MessagingManager.shared.uploadMessage(message: message, completion: completion)
        }
    }
    
}
