//
//  MessagesController+MediaPickers.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase
import AVFoundation

extension MessagesController:   UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate {

    // MARK:- Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.handleVideoSelected(videoUrl)
        } else {
            self.handleImageSelected(info)
        }
        dismiss(animated: true)
    }
    
    private func handleImageSelected(_ info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        guard let image = selectedImageFromPicker, let conversation = conversation else {return}
        let isFirstMessage = self.messages.count == 0 ? true : false
        let uploader = MediaMessageUploader(image: image, conversation: conversation, isFirstMessage: isFirstMessage)
        let uploadTask = uploader.uploadMessage { success  in
            if !success {
                print("Error uploading image message!")
            }
        }
        guard let task = uploadTask else {return}
        self.updateProgressBar(withUploadTask: task)
    }
    
    private func handleVideoSelected(_ videoFileUrl: URL) {
        do {
            guard let conversation = self.conversation else {return}
            let videoData = try Data(contentsOf: videoFileUrl)
            let isFirstMessage = self.messages.count == 0 ? true : false
            let uploader = MediaMessageUploader(video: videoData,
                                                videoFileUrl: videoFileUrl,
                                                conversation: conversation,
                                                isFirstMessage: isFirstMessage)
            let uploadTask = uploader.uploadMessage { success in
                if !success {
                    print("Error uploading video message!")
                }
            }
            guard let task = uploadTask else {return}
            self.updateProgressBar(withUploadTask: task)
        } catch {
            print("Error loading video to data object: \(error.localizedDescription)")
        }
    }
    
    private func updateProgressBar(withUploadTask uploadTask: StorageUploadTask) {
        var progressBarPercentage: Float = 0
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let self = self else {return}
            if (snapshot.progress?.completedUnitCount) != nil {
                if progressBarPercentage < 75 {
                    progressBarPercentage += 15
                    self.animateProgressBar(percentageComplete: progressBarPercentage)
                }
            }
        }
        uploadTask.observe(.success) { [weak self] (snapshot) in
            self?.animateProgressBar(percentageComplete: 100)
        }
    }
    
    private func animateProgressBar(percentageComplete: Float) {
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
    
    private func openImagePicker(_ atCamera: Bool) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        if atCamera == true {
            imagePickerController.sourceType = .camera
        }
        self.present(imagePickerController, animated: true)
    }
    
    @IBAction private func imageMessageButtonPressed(_ sender: Any) {
        openImagePicker(false)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        openImagePicker(true)
    }
    
}
