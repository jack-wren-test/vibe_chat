//
//  UserProfileController+Methods.swift
//  VibeChat
//
//  Created by Jack Smith on 10/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension UserProfileController {
    
    public func disableAllFields() {
        form.subviews.forEach { (view) in
            view.isUserInteractionEnabled = false
        }
    }
    
    public func setInitialFormValues() {
        if let currentUserData = CurrentUser.shared.data {
            nameTF.text = currentUserData.name
            vibeTF.text = currentUserData.vibe
            emailTF.text = currentUserData.email
            profileImageView.image = currentUserData.profileImage
        }
    }
    
    @objc func updateUserData() {
        guard let currentUserData = CurrentUser.shared.data else {return}
        if let text = nameTF.text, text != "" { currentUserData.name = text }
        if let text = vibeTF.text, text != "" { currentUserData.vibe = text }
        if let text = emailTF.text, text != "" { currentUserData.email = text }
    }
    
    public func configureImagePickerController() {
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        imagePickerController?.allowsEditing = true
        imagePickerController?.mediaTypes = ["public.image"]
        imagePickerController?.sourceType = .photoLibrary
    }
    
    @objc func handleProfileImageTapped() {
        if let imagePicker = imagePickerController {
            present(imagePicker, animated: true)
        }
    }
    
}
