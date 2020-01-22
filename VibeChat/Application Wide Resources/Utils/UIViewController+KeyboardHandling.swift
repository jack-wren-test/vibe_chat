//
//  UIViewController+.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Extention adds default functionality for animating a view controller when the keyboard is shown.
/// Functions designed to be overriden in special cases.
extension UIViewController {
    
    // MARK:- Additional Properties
    
    fileprivate struct keyboard {
        static var isHidden: Bool = true
    }
    
    public var keyboardIsHidden: Bool {
        get {
            return keyboard.isHidden
        }
        set {
            keyboard.isHidden = newValue
        }
    }
    
    // MARK:- Methods
    
    public func registerForKeyboardWillShow() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    public func registerForKeyboardWillHide() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    public func registerForKeyboardWillChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardDidChangeFrameNotification,
            object: nil
        )
    }
    
    public func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc public func animateViewWithKeyboard(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let adjustment = -keyboardHeight
            UIView.animate(withDuration: 0.5) {
                self.view.frame = CGRect(x: 0, y: adjustment, width: self.view.frame.width, height: self.view.frame.height)
            }
        }
    }
    
    // MARK:- ObjC Methods
    
    @objc public func keyboardWillShow(_ notification: Notification) {
        animateViewWithKeyboard(notification)
        keyboardIsHidden = false
    }

    @objc public func keyboardWillChange(_ notification: Notification) {
        if keyboardIsHidden == false {
            animateViewWithKeyboard(notification)
        }
    }
    
    @objc public func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
        keyboardIsHidden = true
    }
    
    @objc fileprivate func dismissKeyboard() {
        if UIApplication.shared.isKeyboardShowing {
            view.endEditing(true)
        }
    }
    
}
