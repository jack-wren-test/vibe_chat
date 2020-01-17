//
//  StorageClient.swift
//  VibeChat
//
//  Created by Jack Smith on 06/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Enumeration for the various Firebase storage locations used in application.
enum storageLocation: String {
    case profileImages, messageImages, videos, videoThumbnails
}

/// Class for managing requests from the Firebase Storage API.
final class StorageManager {
    
    // MARK:- Properties
    
    static let shared = StorageManager()
    
    private let ref = Storage.storage().reference()
    
    private lazy var profileImagesRef = ref.child(storageLocation.profileImages.rawValue)
    private lazy var messageImagesRef = ref.child(storageLocation.messageImages.rawValue)
    private lazy var videosRef = ref.child(storageLocation.videos.rawValue)
    private lazy var videoThumbnailsRef = ref.child(storageLocation.videoThumbnails.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    /// Upload the current user's profile image to Firebase Storage.
    /// - Parameters:
    ///   - forUser: The user for profile image update
    ///   - completion: Completion handler passing optional URL object
    public func uploadProfileImage(forUser: User, completion: @escaping (URL?)->Void) {
        guard let data = forUser.profileImage.jpegData(compressionQuality: 0.1) else {return}
        let imageRef = self.profileImagesRef.child(forUser.uid+".jpg")
        imageRef.putData(data, metadata: nil) { [weak self] metadata, error in
            guard let self = self else {return}
            if let error = error {
                print("Error uploading image data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            self.downloadUrl(forReference: imageRef, completion: completion)
        }
    }
    
    /// Upload an image message to Firebase Storage
    /// - Parameters:
    ///   - image: Image to upload
    ///   - completion: Completion handler passing optional URL object
    public func uploadImageMessage(image: UIImage,
                                   completion: @escaping (URL?)->Void) -> StorageUploadTask? {
        let imageRef = self.messageImagesRef.child(NSUUID().uuidString)
        let uploadTask = uploadImage(image: image, toReference: imageRef) { url in
            guard let url = url else {completion(nil); return }
            completion(url)
        }
        return uploadTask
    }
    
    /// Upload a video thumbnail to Firebase Storage.
    /// - Parameters:
    ///   - image: Image to upload
    ///   - completion: Completion handler passing an optional URL object
    public func uploadVideoThumbnail(image: UIImage, completion: @escaping (URL?)->Void) {
        let imageRef = self.videoThumbnailsRef.child(NSUUID().uuidString)
        let _ = uploadImage(image: image, toReference: imageRef) { url in
            guard let url = url else {completion(nil); return }
            completion(url)
        }
    }
    
    /// Upload a video message to Firebase Storage.
    /// - Parameters:
    ///   - video: Video data to upload
    ///   - completion: Completion handler passing an optional URL object
    public func uploadVideoMessage(video: Data, completion: @escaping (URL?)->Void) -> StorageUploadTask {
        var videoName = NSUUID().uuidString
        videoName.append(contentsOf: ".mov")
        let videoRef = self.videosRef.child(videoName)
        let task = videoRef.putData(video, metadata: nil) { [weak self] metadata, error in
            guard let self = self else {return}
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
                completion(nil)
                return
            }
            self.downloadUrl(forReference: videoRef, completion: completion)
        }
        return task
    }
    
    /// Download an image.
    /// - Parameters:
    ///   - url: Url to download image from
    ///   - completion: Completion handler passing an optional UIImage object
    public func downloadImageFromUrl(url: URL, completion: @escaping (UIImage?)->Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {completion(nil); return}
            DispatchQueue.main.async {
                completion(image)
                return
            }
        }.resume()
    }
    
    /// Upload an image to specified reference.
    /// - Parameters:
    ///   - image: Image to upload
    ///   - toReference: Reference to Firebase Storage location
    ///   - completion: Completion handler passing an optional URL object
    private func uploadImage(image: UIImage,
                             toReference: StorageReference,
                             completion: @escaping (URL?)->Void) -> StorageUploadTask? {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {return nil}
        let storageTask = toReference.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard let self = self else {return}
            if let error = error {
                print("Error occured uploading image message: \(error.localizedDescription)")
                completion(nil)
                return
            }
            self.downloadUrl(forReference: toReference, completion: completion)
        }
        return storageTask
    }
    
    /// Download image Url from Firebase storage reference
    /// - Parameters:
    ///   - forReference: Firebase storage reference
    ///   - completion: Compltion handler passing optional URL object
    private func downloadUrl(forReference: StorageReference, completion: @escaping (URL?)->Void) {
        forReference.downloadURL { url, error in
            if let error = error {
                print("Error downloading image url: \(error)")
                completion(nil)
            }
            guard let url = url else {return}
            completion(url)
        }
    }
    
}
