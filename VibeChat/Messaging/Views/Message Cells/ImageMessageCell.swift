//
//  ImageMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

class ImageMessageCell: MessageCell {
    
    // MARK:- Properties
    
    var message: ImageMessage? {
        didSet {
            guard let message = message, let user = CurrentUser.shared.data, let url = message.imageUrl else {return}
            imageMessageView.loadImageUsingCacheWithUrl(url: url) { (image) in
                if image != nil {
                    let isOutgoingMessage = message.fromUid == user.uid
                    self.layoutMessage(isOutgoingMessage)
                    self.updateHeightAnchor(usingAspectRatio: message.aspectRatio)
                }
            }
        }
    }
    
    lazy var imageMessageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        return imageView
    }()
    
    var controllerDelegate: ImageMessageDelegate?
    var viewHeightAnchor: NSLayoutConstraint?
    
    // MARK:- Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        message = nil
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        addSubview(imageMessageView)
        incomingXConstraint = imageMessageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        outgoingXConstraint = imageMessageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        imageMessageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageMessageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageMessageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    public func updateHeightAnchor(usingAspectRatio: CGFloat) {
        let viewHeightAnchor = heightAnchor.constraint(equalToConstant: 200/usingAspectRatio)
        viewHeightAnchor.priority = UILayoutPriority.required
        viewHeightAnchor.isActive = true
    }
    
    @objc public func handleImageTap() {
        controllerDelegate?.imageMessageTapped(imageMessageView, nil, nil)
    }
    
}
