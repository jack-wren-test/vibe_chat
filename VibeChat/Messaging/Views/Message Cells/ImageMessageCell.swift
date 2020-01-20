//
//  ImageMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

/// Class for an image message cell.
class ImageMessageCell: MessageCell {
    
    // MARK:- Properties
    
    lazy var imageMessageView: UIImageView? = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        return imageView
    }()
    
    weak var controllerDelegate: ImageInteractionDelegate?
    
    // MARK:- Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didMoveToSuperview() {
        guard let message = message as? ImageMessage else {return}
        self.updateHeightAnchor(usingAspectRatio: message.aspectRatio)
    }
    
    override func prepareForReuse() {
        self.imageMessageView = nil
        self.message = nil
    }
    
    // MARK:- Methods
    
    override func setupMessage() {
        super.setupMessage()
        guard let message = self.message as? ImageMessage, let url = message.imageUrl else {return}
        guard let imageMessageView = self.imageMessageView else {return}
        imageMessageView.loadImageUsingCacheOrUrl(url: url)
    }
    
    private func configureViews() {
        guard let imageMessageView = self.imageMessageView else {return}
        self.addSubview(imageMessageView)
        self.incomingXConstraint = imageMessageView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                                             constant: self.edgeBuffer)
        self.outgoingXConstraint = imageMessageView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                                              constant: -self.edgeBuffer)
        imageMessageView.widthAnchor.constraint(equalToConstant: self.maxMessageWidth).isActive = true
        imageMessageView.topAnchor.constraint(equalTo: self.topAnchor,
                                              constant: self.cellBuffer).isActive = true
        imageMessageView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                 constant: -self.cellBuffer).isActive = true
    }
    
    public func updateHeightAnchor(usingAspectRatio aspectRatio: CGFloat) {
        self.viewHeightAnchor = heightAnchor.constraint(equalToConstant: self.maxMessageWidth/aspectRatio)
        self.viewHeightAnchor?.priority = UILayoutPriority.init(rawValue: 999)
        self.viewHeightAnchor?.isActive = true
    }
    
    @objc public func handleImageTap() {
        guard let imageMessageView = imageMessageView else {return}
        self.controllerDelegate?.imageMessageTapped(imageMessageView, nil, nil)
    }
    
}
