//
//  User.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Model for a user.
class User {
    
    // MARK:- Properties
    
    private let profileImageCache = NSCache<NSString, UIImage>()
    
    public var name: String
    public var uid: String
    public var vibe: String?
    public var email: String
    public var profileImage = UIImage(imageLiteralResourceName: "profile").withRenderingMode(.alwaysTemplate).withTintColor(.white)
    
    public var profileImageUrl: URL? {
        didSet {
            profileImageFromChacheOrDb { (image) in
                self.profileImage = image
            }
        }
    }
    
    public var isOnline: Bool {
        didSet {
            UsersManager.shared.toggleIsOnline(user: self)
        }
    }
    
    // MARK:- Init
    
    
    
    /// Init from submitted details. For use when a user is created with the application.
    /// - Parameters:
    ///   - uid: Unique identifier
    ///   - name: User name
    ///   - email: Users email address
    init(uid: String, name: String, email: String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.isOnline = true // If we were initialising this way, the current user is always online.
    }
    
    
    /// Init from a [String: Any] dictionary. For use when creating a user object with details from Firestore.
    /// - Parameter withDictionary: Dictionary of user parameters.
    init(withDictionary: [String: Any]) {
        name = withDictionary["name"] as! String
        uid = withDictionary["uid"] as! String
        email = withDictionary["email"] as! String
        vibe = withDictionary["vibe"] as? String
        isOnline = withDictionary["isOnline"] as! Bool
        if let profileImageUrlString = withDictionary["profileImageUrl"] as? String {
            self.profileImageUrl = URL(string: profileImageUrlString)
            profileImageFromChacheOrDb { (image) in
                self.profileImage = image
            }
        }
    }
    
    // MARK:- Methods
    
    /// Rreturn a dictionary object representation of the user.
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = ["name": name, "uid": uid,
                                   "email": email, "isOnline": isOnline]
        addToDictIfNotNil(&dict, profileImageUrl?.absoluteString, "profileImageUrl")
        addToDictIfNotNil(&dict, vibe, "vibe")
        return dict
    }
    
    
    /// Acquire the users profile image, checks the current imageUrl for the user and returns the cached image or
    /// fetches image from Firebase storage.
    /// - Parameter completion: Completes with a returned UIImage.
    public func profileImageFromChacheOrDb(completion: @escaping (_ image: UIImage)->()) {
        guard let url = profileImageUrl else {return}
        if let image = profileImageCache.object(forKey: url.absoluteString as NSString) {
            completion(image)
        } else {
            StorageManager.shared.downloadImageFromUrl(url: url) { [weak self] (image) in
                if let image = image {
                    completion(image)
                    self?.profileImageCache.setObject(image, forKey: url.absoluteString as NSString)
                }
            }
        }
    }
    
    
    /// Convenience method for adding an optional value to dictionary if != nil.
    /// - Parameters:
    ///   - dict: The dictionary object to be added to.
    ///   - item: The object to be added.
    ///   - key: The key for accessing the item.
    private func addToDictIfNotNil(_ dict: inout Dictionary<String, Any>, _ item: Any?, _ key: String) {
        if let item = item {
            dict[key] = item
        }
    }
    
    // ^ Useful in other areas of progran, extend dictionary?
    
}
