//
//  MessagesController+MediaPickers.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

extension MessagesController: UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate {

    // MARK:- Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelected(videoUrl)
        } else {
            handleImageSelected(info)
        }
        dismiss(animated: true)
        
    }
    
    fileprivate func handleImageSelected(_ info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let image = selectedImageFromPicker {
            StorageManager.shared.uploadImageMessage(image: image) { (url) in
                if let url = url {
                    self.sendImageMessageWithUrl(url: url)
                }
            }
        }
    }
    
    fileprivate func sendImageMessageWithUrl(url: URL) {
        guard let conversation = conversation else {return}
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = ImageMessage(imageUrl: url, toUid: conversation.chatter!.uid, fromUid: CurrentUser.shared.data!.uid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message)
            }
        }
    }
    
    fileprivate func handleVideoSelected(_ videoFileUrl: URL) {
        do {
            let videoData = try Data(contentsOf: videoFileUrl)
            let uploadTask = StorageManager.shared.uploadVideoMessage(video: videoData) { (uploadedVideoUrl) in
                if let uploadedVideoUrl = uploadedVideoUrl {
                    if let thumbnailImage = self.thumbnailImageForVideoUrl(videoFileUrl: videoFileUrl) {
                        StorageManager.shared.uploadVideoThumbnail(image: thumbnailImage) { (url) in
                            if let thumbnailImageUrl = url {
                                let aspectRatio = thumbnailImage.size.width / thumbnailImage.size.height
                                self.sendVideoMessageWithUrl(videoUrl: uploadedVideoUrl,
                                                             thumbnailUrl: thumbnailImageUrl,
                                                             aspectRatio: aspectRatio)
                            }
                        }
                    }
                }
            }
            var progressBarPercentage: Float = 0
            uploadTask.observe(.progress) { [unowned self] (snapshot) in
                if (snapshot.progress?.completedUnitCount) != nil {
                    if progressBarPercentage < 75 {
                        progressBarPercentage += 15
                        self.updateProgressBar(percentageComplete: progressBarPercentage)
                    }
                }
            }
            uploadTask.observe(.success) { [unowned self] (snapshot) in
                self.updateProgressBar(percentageComplete: 100)
            }
        } catch {
            print("Error loading video to data object: \(error.localizedDescription)")
        }
    }
    
    fileprivate func thumbnailImageForVideoUrl(videoFileUrl: URL) -> UIImage? {
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
    
    fileprivate func sendVideoMessageWithUrl(videoUrl: URL, thumbnailUrl: URL, aspectRatio: CGFloat) {
        guard let conversation = conversation else {return}
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = VideoMessage(videoUrl: videoUrl, thumbnailImageUrl: thumbnailUrl, aspectRatio: aspectRatio, toUid: conversation.chatter!.uid, fromUid: CurrentUser.shared.data!.uid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message)
            }
        }
    }
    
    fileprivate func updateProgressBar(percentageComplete: Float) {
        let phoneWidth = view.frame.width
        let newWidth = CGFloat(percentageComplete/100)*phoneWidth
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.progressBarWidthAnchor.constant = newWidth
            self.view.layoutIfNeeded()
        }) { (_) in
            if percentageComplete == 100 {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.progressBarWidthAnchor.constant = newWidth
                    self.view.layoutIfNeeded()
                }) {(_) in self.progressBarWidthAnchor.constant = 0}
            }
        }
    }
    
    // MARK:- IBActions
    
    @IBAction func imageMessageButtonPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true)
    }
    
}
