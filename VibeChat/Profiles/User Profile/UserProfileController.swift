//
//  ProfileController.swift
//  VibeChat
//
//  Created by Jack Smith on 06/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Controller for user profile view.
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
    }
    
    deinit {
        print("Profile controller deinitialized")
    }
    
    // MARK:- IBActions
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.homeDelegate?.performLogOut()
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        defer {self.dismiss(animated: true)}
        updateUserData()
        if let image = profileImageView.image, let currentUserData = CurrentUser.shared.data {
            currentUserData.profileImage = image
            StorageManager.shared.uploadProfileImage(forUser: currentUserData) { (url) in
                currentUserData.profileImageUrl = url
                CurrentUser.shared.updateUserDataInDb()
            }
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
