//
//  GiphyManager.swift
//  VibeChat
//
//  Created by Jack Smith on 31/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import GiphyUISDK
import GiphyCoreSDK

final class GiphyManager {

    // MARK:- Singleton Setup
    static let shared = GiphyManager()

    // MARK:- Private Init (Force Singleton)

    private func Init() {}

    // MARK:- Methods
    
    public func requestGif(withId: String, completion: @escaping (GPHMedia?)->()) {
        
        GiphyCore.shared.gifByID(withId) { (response, error) in
            if let error = error {
                print("Error downloading Giph: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let media = response?.data {
                DispatchQueue.main.async {
                    completion(media)
                }
            }
        }
        
    }

}