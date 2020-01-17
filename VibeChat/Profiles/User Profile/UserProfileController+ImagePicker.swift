//
//  UserProfileController+ImagePicker.swift
//  VibeChat
//
//  Created by Jack Smith on 10/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension UserProfileController: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerController?.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.imagePickerController?.dismiss(animated: true)
            }
        }
        self.imagePickerController?.dismiss(animated: true)
    }
}
