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
    case profileImages
}

class StorageManager {
    
    // MARK:- Singleton Setup
    static let shared = StorageManager()
    
    // MARK:- Properties
    
    private let ref = Storage.storage().reference()
    private lazy var profileImagesRef = ref.child(storageLocation.profileImages.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    public func uploadProfileImageDataUnderUid(uid: String, image: UIImage, completion: @escaping (String?)->()) {
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            print("Error parsing image to Data object...")
            return
        }
        let imageRef = profileImagesRef.child(uid+".jpg")
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image data: \(error.localizedDescription)")
                completion(nil)
            }
            self.downloadImageUrl(forReference: imageRef) { (url) in
                completion(url)
            }
        }
    }
    
    public func downloadProfileImageForUrl(url: String, completion: @escaping (UIImage?)->()) {
        let imageUrl = URL(string: url)
        guard let url = imageUrl else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
            } else {
                if let image = UIImage(data: data!) {
                    completion(image)
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
    
    private func downloadImageUrl(forReference: StorageReference, completion: @escaping (String?)->()) {
        forReference.downloadURL { (url, error) in
            if let error = error {
                print("Error downloading image url: \(error)")
                completion(nil)
            }
            completion(url?.absoluteString)
        }
    }
    
}
