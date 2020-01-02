//
//  User.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class User {
    
    // MARK:- Properties
    
    public var name: String
    public var uid: String
    public var status: String?
    public var vibe: String?
    public var email: String
    public var isOnline: Bool {
        didSet {
            UsersManager.shared.toggleIsOnline(user: self)
        }
    }
    
    public let imageCache = NSCache<NSString, UIImage>()
    public var profileImage = UIImage(imageLiteralResourceName: "profile").withRenderingMode(.alwaysTemplate)
    public var profileImageUrl: URL? {
        didSet {
            imageFromChacheOrDb { (image) in
                self.profileImage = image
            }
        }
    }
    
    // MARK:- Initializers
    
    init(withDictionary: [String: Any]) {
        name = withDictionary["name"] as! String
        uid = withDictionary["uid"] as! String
        email = withDictionary["email"] as! String
        vibe = withDictionary["vibe"] as? String
        status = withDictionary["status"] as? String
        isOnline = withDictionary["isOnline"] as! Bool
        if let profileImageUrlString = withDictionary["profileImageUrl"] as? String {
            self.profileImageUrl = URL(string: profileImageUrlString)
            imageFromChacheOrDb { (image) in
                self.profileImage = image
            }
        } else {
            profileImage = UIImage(imageLiteralResourceName: "profile")
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(.white)
        }
    }
    
    // MARK:- Methods
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = ["name": name,
                                   "uid": uid,
                                   "email": email,
                                   "isOnline": isOnline]
        if let profileImageUrl = profileImageUrl {dict["profileImageUrl"] = profileImageUrl}
        if let status = status {dict["status"] = status}
        if let vibe = vibe {dict["vibe"] = vibe}
        return dict
    }
    
    public func imageFromChacheOrDb(completion: @escaping (_ image: UIImage)->()) {
        guard let url = profileImageUrl else {return}
        if let image = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(image)
        } else {
            StorageManager.shared.downloadImageFromUrl(url: url) { [weak self] (image) in
                if let image = image {
                    completion(image)
                    self?.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                }
            }
        }
    }
    
}
