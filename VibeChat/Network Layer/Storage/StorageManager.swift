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
    typealias RawValue = String
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
    ///   - completion: Completion handler returning optional URL object
    public func uploadProfileImage(forUser: User, completion: @escaping (URL?)->()) {
        guard let data = forUser.profileImage.jpegData(compressionQuality: 0.1) else {return}
        let imageRef = profileImagesRef.child(forUser.uid+".jpg")
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            self.downloadImageUrl(forReference: imageRef) { (url) in
                completion(url)
            }
        }
    }
    
    /// Upload an image message to Firebase Storage
    /// - Parameters:
    ///   - image: Image to upload
    ///   - completion: Completion handler returning optional URL object
    public func uploadImageMessage(image: UIImage, completion: @escaping (URL?)->()) {
        let imageRef = messageImagesRef.child(NSUUID().uuidString)
        uploadImage(image: image, toReference: imageRef) { (url) in
            if let url = url { completion(url); return }
            completion(nil)
        }
    }
    
    /// Upload a video thumbnail to Firebase Storage.
    /// - Parameters:
    ///   - image: Image to upload
    ///   - completion: Completion handler returning an optional URL object
    public func uploadVideoThumbnail(image: UIImage, completion: @escaping (URL?)->()) {
        let imageRef = videoThumbnailsRef.child(NSUUID().uuidString)
        uploadImage(image: image, toReference: imageRef) { (url) in
            if let url = url { completion(url); return }
            completion(nil)
        }
    }
    
    /// Upload a video message to Firebase Storage.
    /// - Parameters:
    ///   - video: Video data to upload
    ///   - completion: Completion handler returning an optional URL object
    public func uploadVideoMessage(video: Data, completion: @escaping (URL?)->()) -> StorageUploadTask {
        var videoName = NSUUID().uuidString
        videoName.append(contentsOf: ".mov")
        let videoRef = videosRef.child(videoName)
        let task = videoRef.putData(video, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
                completion(nil)
                return
            }
            videoRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error downloading video url: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                if let url = url {
                    completion(url.absoluteURL)
                }
            }
        }
        return task
    }
    
    /// Upload an image to specified reference.
    /// - Parameters:
    ///   - image: Image to upload
    ///   - toReference: Reference to Firebase Storage location
    ///   - completion: Completion handler returning an optional URL object
    private func uploadImage(image: UIImage, toReference: StorageReference, completion: @escaping (URL?)->()) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {return}
        toReference.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error occured uploading image message: \(error.localizedDescription)")
                completion(nil)
                return
            }
            self.downloadImageUrl(forReference: toReference) { (url) in
                completion(url)
            }
        }
    }
    
    /// Download an image.
    /// - Parameters:
    ///   - url: Url to download image from
    ///   - completion: Completion handler returning an optional UIImage object
    public func downloadImageFromUrl(url: URL, completion: @escaping (UIImage?)->()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            } else {
                if let image = UIImage(data: data!) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    /// Download image Url from Firebase storage reference
    /// - Parameters:
    ///   - forReference: Firebase storage reference
    ///   - completion: Compltion handler returning optional URL object
    private func downloadImageUrl(forReference: StorageReference, completion: @escaping (URL?)->()) {
        forReference.downloadURL { (url, error) in
            if let error = error {
                print("Error downloading image url: \(error)")
                completion(nil)
            }
            if let url = url {
                completion(url)
            }
        }
    }
    
}
