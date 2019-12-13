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
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var form: UIStackView!
    @IBOutlet weak var nameTF: AuthenticationTextField!
    @IBOutlet weak var statusTF: AuthenticationTextField!
    @IBOutlet weak var vibeTF: AuthenticationTextField!
    @IBOutlet weak var emailTF: AuthenticationTextField!
    
    // MARK:- Properties
    
    var user: User?
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
        nameTF.text = user?.name
        statusTF.text = user?.status
        vibeTF.text = user?.vibe
        emailTF.text = user?.email
        profileImageView.image = user?.profileImage
        profileImageView.tintColor = .white        
    }
    
    // MARK:- IBActions
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.homeDelegate?.performLogOut()
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let user = user else {dismiss(animated: true); return}
        UsersManager.shared.updateUserData(toUserUid: user.uid, withData: user.toDict()) {
            self.homeDelegate?.updateUserData(data: user)
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
                user?.name = text
            }
        case let tf where sender == statusTF:
            if let text = tf.text {
                user?.status = text
            }
        case let tf where sender == vibeTF:
            if let text = tf.text {
                user?.vibe = text
            }
        case let tf where sender == emailTF:
            if let text = tf.text {
                user?.email = text
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            DispatchQueue.main.async {
                self.user?.profileImage = image
                self.profileImageView.image = image
                self.imagePickerController?.dismiss(animated: true)
            }
            guard let uid = self.user?.uid else {return}
            StorageManager.shared.uploadProfileImageDataUnderUid(uid: uid, image: image) { (url) in
                print("Changed photo url: \(url)")
                self.user?.profileImageUrl = url
            }
        }
        imagePickerController?.dismiss(animated: true)
    }
    
}
