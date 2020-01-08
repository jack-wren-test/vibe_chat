//
//  ProfileController.swift
//  VibeChat
//
//  Created by Jack Smith on 06/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class UserProfileController: UIViewController,
                         UINavigationControllerDelegate,
                         UITextFieldDelegate {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var form: UIStackView!
    @IBOutlet weak var nameTF: AuthenticationTextField!
    @IBOutlet weak var vibeTF: AuthenticationTextField!
    @IBOutlet weak var emailTF: AuthenticationTextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK:- Properties
    
    var chatter: User? {
        didSet {
            guard let user = chatter, let currentUser = CurrentUser.shared.data else {return}
            isCurrentUsersProfile = currentUser.uid == user.uid
        }
    }
    
    var homeDelegate: HomeDelegate?
    var imagePickerController: UIImagePickerController?
    
    // MARK:- Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardWillShow()
        registerForKeyboardWillChange()
        registerForKeyboardWillHide()
        setupTapToDismissKeyboard()
        setInitialFormValues()
        configureImagePickerController()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        configureForChatterIfNeeded()
    }
    
    // MARK:- IBActions
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.homeDelegate?.performLogOut()
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        updateUserData()
        if let image = profileImageView.image, let currentUserData = CurrentUser.shared.data {
            currentUserData.profileImage = image
            StorageManager.shared.uploadProfileImageDataUnderUid(uid: currentUserData.uid, image: image) { (url) in
                currentUserData.profileImageUrl = url
            }
        }
        CurrentUser.shared.updateUserDataInDb() { self.dismiss(animated: true) }
    }
    
    
    // MARK:- Methods
    
    fileprivate func configureForChatterIfNeeded() {
        if !isCurrentUsersProfile {
            saveButton.isHidden = true
            logOutButton.isHidden = true
            disableAllFields()
        }
    }
    
    fileprivate func disableAllFields() {
        form.subviews.forEach { (view) in
            view.isUserInteractionEnabled = false
        }
    }
    
    fileprivate func setInitialFormValues() {
        if isCurrentUsersProfile, let currentUserData = CurrentUser.shared.data {
            nameTF.text = currentUserData.name
            vibeTF.text = currentUserData.vibe
            emailTF.text = currentUserData.email
            profileImageView.image = currentUserData.profileImage
        } else if let chatter = chatter {
            nameTF.text = chatter.name
            vibeTF.text = chatter.vibe
            emailTF.text = chatter.email
            profileImageView.image = chatter.profileImage
        }
    }
    
    @objc func updateUserData() {
        guard let currentUserData = CurrentUser.shared.data else {return}
        if let text = nameTF.text { currentUserData.name = text }
        if let text = vibeTF.text { currentUserData.vibe = text }
        if let text = emailTF.text { currentUserData.email = text }
    }
    
    fileprivate func configureImagePickerController() {
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        imagePickerController?.allowsEditing = true
        imagePickerController?.mediaTypes = ["public.image"]
        imagePickerController?.sourceType = .photoLibrary
    }
    
    @objc func handleProfileImageTapped() {
        if isCurrentUsersProfile, let imagePicker = imagePickerController {
            present(imagePicker, animated: true)
        }
    }
    
    // MARK:- UITextField Delegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 28
    }


}

extension UserProfileController: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController?.dismiss(animated: true)
    }
    
    // UGLY, REFACTOR
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.imagePickerController?.dismiss(animated: true)
            }
        }
        imagePickerController?.dismiss(animated: true)
    }
    
}
