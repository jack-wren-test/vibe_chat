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
    
    private(set) var uid: String
    
    public var name: String
    public var email: String
    public var vibe: String?
    
    public var profileImage = UIImage(imageLiteralResourceName: "profile").withRenderingMode(.alwaysTemplate).withTintColor(.white)
    
    public var profileImageUrl: URL? {
        didSet {
            profileImageFromChacheOrDb { [weak self] (image) in
                self?.profileImage = image
            }
        }
    }
    
    public var isOnline: Bool {
        didSet {
            UsersManager.shared.toggleIsOnline(user: self, completion: nil)
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
        self.name = withDictionary["name"] as! String
        self.uid = withDictionary["uid"] as! String
        self.email = withDictionary["email"] as! String
        self.vibe = withDictionary["vibe"] as? String
        self.isOnline = withDictionary["isOnline"] as! Bool
        guard let profileImageUrlString = withDictionary["profileImageUrl"] as? String else {return}
        self.profileImageUrl = URL(string: profileImageUrlString)
        profileImageFromChacheOrDb { [weak self] image in
            guard let self = self else {return}
            self.profileImage = image
        }
    }
    
    // MARK:- Methods
    
    /// Rreturn a dictionary object representation of the user.
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = ["name": self.name, "uid": self.uid,
                                   "email": self.email, "isOnline": self.isOnline]
        addToDictIfNotNil(&dict, profileImageUrl?.absoluteString, "profileImageUrl")
        addToDictIfNotNil(&dict, vibe, "vibe")
        return dict
    }
    
    /// Acquire the users profile image, checks the current imageUrl for the user and returns the cached image or
    /// fetches image from Firebase storage.
    /// - Parameter completion: Completes with a returned UIImage.
    public func profileImageFromChacheOrDb(completion: @escaping (_ image: UIImage)->()) {
        guard let url = profileImageUrl else {return}
        if let image = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(image)
        } else {
            StorageManager.shared.downloadImageFromUrl(url: url) { image in
                guard let image = image else {return}
                completion(image)
                imageCache.setObject(image, forKey: url.absoluteString as NSString)
            }
        }
    }
    
    /// Convenience method for adding an optional value to dictionary if != nil.
    /// - Parameters:
    ///   - dict: The dictionary object to be added to.
    ///   - item: The object to be added.
    ///   - key: The key for accessing the item.
    private func addToDictIfNotNil(_ dict: inout Dictionary<String, Any>, _ item: Any?, _ key: String) {
        guard let item = item else {return}
        dict[key] = item
    }
    
    // ^ Useful in other areas of progran, extend dictionary?
    
}
