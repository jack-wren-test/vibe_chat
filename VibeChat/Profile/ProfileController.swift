//
//  ProfileController.swift
//  VibeChat
//
//  Created by Jack Smith on 06/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class ProfileController: UIViewController, UINavigationControllerDelegate {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var form: UIStackView!
    @IBOutlet weak var nameTF: AuthenticationTextField!
    @IBOutlet weak var statusTF: AuthenticationTextField!
    @IBOutlet weak var vibeTF: AuthenticationTextField!
    @IBOutlet weak var emailTF: AuthenticationTextField!
    
    // MARK:- Properties
    
    var homeDelegate: HomeDelegate?
    var imagePickerController: UIImagePickerController?
    
    // MARK:- ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardWillShow()
        registerForKeyboardWillChange()
        registerForKeyboardWillHide()
        addTextFieldDidChangeActions()
        setupTapToDismissKeyboard()
        setInitialFormValues()
        
        configureImagePickerController()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
    }
    
    fileprivate func setInitialFormValues() {
        nameTF.text = CurrentUser.shared.data?.name
        statusTF.text = CurrentUser.shared.data?.status
        vibeTF.text = CurrentUser.shared.data?.vibe
        emailTF.text = CurrentUser.shared.data?.email
        profileImageView.image = CurrentUser.shared.data?.profileImage
        profileImageView.tintColor = .white        
    }
    
    // MARK:- IBActions
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.homeDelegate?.performLogOut()
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        CurrentUser.shared.updateUserDataInDb() {
            self.dismiss(animated: true)
        }
    }
    
    
    // MARK:- Methods
    
    fileprivate func addTextFieldDidChangeActions() {
        form.subviews.forEach { (view) in
            if let tf = view as? AuthenticationTextField {
                tf.addTarget(self, action: #selector(updateUserData(_:)), for: .editingChanged)
            }
        }
    }
    
    @objc func updateUserData(_ sender: UITextField) {
        switch sender {
        case let tf where sender == nameTF:
            if let text = tf.text {
                CurrentUser.shared.data?.name = text
            }
        case let tf where sender == statusTF:
            if let text = tf.text {
                CurrentUser.shared.data?.status = text
            }
        case let tf where sender == vibeTF:
            if let text = tf.text {
                CurrentUser.shared.data?.vibe = text
            }
        case let tf where sender == emailTF:
            if let text = tf.text {
                CurrentUser.shared.data?.email = text
            }
        default:
            break
        }
    }
    
    fileprivate func configureImagePickerController() {
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

extension ProfileController: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController?.dismiss(animated: true)
    }
    
    // UGLY, REFACTOR
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            DispatchQueue.main.async {
                CurrentUser.shared.data?.profileImage = image
                self.profileImageView.image = image
                self.imagePickerController?.dismiss(animated: true)
            }
            guard let uid = CurrentUser.shared.data?.uid else {return}
            StorageManager.shared.uploadProfileImageDataUnderUid(uid: uid, image: image) { (url) in
                CurrentUser.shared.data?.profileImageUrl = url
            }
        }
        imagePickerController?.dismiss(animated: true)
    }
    
}
