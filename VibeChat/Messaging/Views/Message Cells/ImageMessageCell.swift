//
//  ImageMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class ImageMessageCell: MessageCell {
    
    // MARK:- Properties
    
    var imageMessage: ImageMessage? {
        didSet {
            guard let imageMessage = imageMessage else {return}
            guard let user = CurrentUser.shared.data else {return}
            guard let url = imageMessage.url else {return}
            imageMessageView.loadImageUsingCacheWithUrlString(urlString: url) { (image) in
                if let image = image {
                    let isOutgoingMessage = imageMessage.fromUid == user.uid
                    self.layoutMessage(isOutgoingMessage)
                    let aspectRatio = image.size.height/image.size.width
                    self.adjustImageWidth(aspectRatio)
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
    
    var controllerDelegate: messagesControllerDelegate?
    
    // MARK:- Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imageMessage = nil
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        addSubview(imageMessageView)
        incomingXConstraint = imageMessageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        outgoingXConstraint = imageMessageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        imageMessageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        imageMessageView.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        imageMessageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        heightAnchor.constraint(equalToConstant: 254).isActive = true
    }
    
    private func adjustImageWidth(_ aspectRatio: CGFloat) {
        imageMessageView.widthAnchor.constraint(equalToConstant: imageMessageView.frame.height*aspectRatio).isActive = true
    }
    
    @objc private func handleImageTap() {
        controllerDelegate?.imageMessageTapped(imageMessageView)
    }
    
    
}
