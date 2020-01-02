//
//  StorageClient.swift
//  VibeChat
//
//  Created by Jack Smith on 06/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

enum storageLocation: String {
    typealias RawValue = String
    case profileImages, messageImages, videos, videoThumbnails
}

final class StorageManager {
    
    // MARK:- Singleton Setup
    static let shared = StorageManager()
    
    // MARK:- Properties
    
    private let ref = Storage.storage().reference()
    private lazy var profileImagesRef = ref.child(storageLocation.profileImages.rawValue)
    private lazy var messageImagesRef = ref.child(storageLocation.messageImages.rawValue)
    private lazy var videosRef = ref.child(storageLocation.videos.rawValue)
    private lazy var videoThumbnailsRef = ref.child(storageLocation.videoThumbnails.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
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
                    print("Success, url: \(url.absoluteString)")
                    completion(url.absoluteURL)
                }
            }
        }
        return task
    }
    
    public func uploadProfileImageDataUnderUid(uid: String, image: UIImage, completion: @escaping (URL?)->()) {
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            print("Error parsing image to Data object...")
            return
        }
        let imageRef = profileImagesRef.child(uid+".jpg")
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
    
    public func uploadImageMessage(image: UIImage, completion: @escaping (URL?)->()) {
        let imageRef = messageImagesRef.child(NSUUID().uuidString)
        uploadImage(image: image, toReference: imageRef) { (url) in
            if let url = url { completion(url); return }
            completion(nil)
        }
    }
    
    public func uploadVideoThumbnail(image: UIImage, completion: @escaping (URL?)->()) {
        let imageRef = videoThumbnailsRef.child(NSUUID().uuidString)
        uploadImage(image: image, toReference: imageRef) { (url) in
            if let url = url { completion(url); return }
            completion(nil)
        }
    }
    
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
    
    public func downloadProfileImageForUid(uid: String, completion: @escaping (UIImage?)->()) {
        let imageRef = profileImagesRef.child(uid+".jpg")
        imageRef.getData(maxSize: 1*1024*1024) { (data, error) in
            if let error = error {
                print("Error downloading image data: \(error.localizedDescription)")
                completion(nil)
            }
            guard let data = data else {return}
            let image = UIImage(data: data)
            completion(image)
        }
    }
    
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
