//
//  UIView+.swift
//  VibeChat
//
//  Created by Jack Smith on 13/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension UIView {
    
    public func constraintsEqual(toView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: toView.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: toView.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: toView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
    }
    
    public func constraintsEqual(toView: UIView, withEqualPadding padding: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: padding).isActive = true
        topAnchor.constraint(equalTo: toView.topAnchor, constant: padding).isActive = true
        trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -padding).isActive = true
        bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: -padding).isActive = true
    }
    
    public func constraintsEqual(toView: UIView, withPadding padding: UIEdgeInsets) {
        translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: padding.left).isActive = true
        topAnchor.constraint(equalTo: toView.topAnchor, constant: padding.top).isActive = true
        trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: padding.right).isActive = true
        bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: padding.bottom).isActive = true
    }
    
}
