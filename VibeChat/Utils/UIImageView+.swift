//
//  UIImageView+.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    public func loadImageUsingCacheWithUrlString(urlString: String, completion: @escaping (_ image: UIImage?)->() = {_ in }) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            completion(cachedImage)
            return
        }
        StorageManager.shared.downloadImageFromUrl(url: urlString) { (image) in
            if let image = image {
                imageCache.setObject(image, forKey: urlString as NSString)
                self.image = image
                completion(image)
                return
            }
            completion(nil)
        }
        
    }
    
}
