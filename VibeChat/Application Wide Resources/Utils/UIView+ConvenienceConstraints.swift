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
    
    public func anchor(centerX: NSLayoutXAxisAnchor?,
                       centerY: NSLayoutYAxisAnchor?,
                       top: NSLayoutYAxisAnchor?,
                       bottom: NSLayoutYAxisAnchor?,
                       leading: NSLayoutXAxisAnchor?,
                       trailing: NSLayoutXAxisAnchor?,
                       padding: UIEdgeInsets?,
                       size: CGSize?) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let top = top {
            let topConstraint = topAnchor.constraint(equalTo: top)
            topConstraint.isActive = true
            guard let topPadding = padding?.top else {return}
            topConstraint.constant = topPadding
        }
        
        if let bottom = bottom {
            let bottomConstraint = bottomAnchor.constraint(equalTo: bottom)
            bottomConstraint.isActive = true
            guard let bottomPadding = padding?.bottom else {return}
            bottomConstraint.constant = -bottomPadding
        }
        
        if let leading = leading {
            let leadingConstraint = leadingAnchor.constraint(equalTo: leading)
            leadingConstraint.isActive = true
            guard let leadingPadding = padding?.left else {return}
            leadingConstraint.constant = leadingPadding
        }
        
        if let trailing = trailing {
            let trailingConstraint = trailingAnchor.constraint(equalTo: trailing)
            trailingConstraint.isActive = true
            guard let trailingPadding = padding?.right else {return}
            trailingConstraint.constant = -trailingPadding
        }
        
        if let size = size {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
    }
    
    public func anchor(centerX: NSLayoutXAxisAnchor?,
                       centerY: NSLayoutYAxisAnchor?,
                       size: CGSize?) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let size = size {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
    }
    
    public func anchor(top: NSLayoutYAxisAnchor?,
                       bottom: NSLayoutYAxisAnchor?,
                       leading: NSLayoutXAxisAnchor?,
                       trailing: NSLayoutXAxisAnchor?,
                       padding: UIEdgeInsets?,
                       size: CGSize?) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            let topConstraint = topAnchor.constraint(equalTo: top)
            topConstraint.isActive = true
            guard let topPadding = padding?.top else {return}
            topConstraint.constant = topPadding
        }
        
        if let bottom = bottom {
            let bottomConstraint = bottomAnchor.constraint(equalTo: bottom)
            bottomConstraint.isActive = true
            guard let bottomPadding = padding?.bottom else {return}
            bottomConstraint.constant = -bottomPadding
        }
        
        if let leading = leading {
            let leadingConstraint = leadingAnchor.constraint(equalTo: leading)
            leadingConstraint.isActive = true
            guard let leadingPadding = padding?.left else {return}
            leadingConstraint.constant = leadingPadding
        }
        
        if let trailing = trailing {
            let trailingConstraint = trailingAnchor.constraint(equalTo: trailing)
            trailingConstraint.isActive = true
            guard let trailingPadding = padding?.right else {return}
            trailingConstraint.constant = -trailingPadding
        }
        
        if let size = size {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
    }
    
}
