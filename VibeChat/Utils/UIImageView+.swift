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
    
    public func loadImageUsingCacheWithUrl(url: URL, completion: @escaping (_ image: UIImage?)->() = {_ in }) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            completion(cachedImage)
            return
        }
        StorageManager.shared.downloadImageFromUrl(url: url) { (image) in
            if let image = image {
                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                self.image = image
                completion(image)
                return
            }
            completion(nil)
        }
        
    }
}
