//
//  UIApplication+IsKeyboardShowing.swift
//  VibeChat
//
//  Created by Jack Smith on 22/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension UIApplication {
    var isKeyboardShowing: Bool {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"), self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
            return true
        } else {
            return false
        }
    }
}
