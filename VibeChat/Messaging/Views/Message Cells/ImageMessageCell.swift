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
                    self.setupVideoLayerIfVideo()
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
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleVideoPlayPause), for: .touchUpInside)
        return button
    }()
    
    var controllerDelegate: ImageMessageDelegate?
    var viewHeightAnchor: NSLayoutConstraint?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var initialVideoMessageFrame: CGRect?
    
    // MARK:- Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        playerLayer?.removeFromSuperlayer()
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
    
    private func updateHeightAnchor(usingAspectRatio: CGFloat) {
        let viewHeightAnchor = heightAnchor.constraint(equalToConstant: 200/usingAspectRatio)
        viewHeightAnchor.priority = UILayoutPriority.required
        viewHeightAnchor.isActive = true
    }
    
    
    fileprivate func setupVideoLayerIfVideo() {
        
        if let message = message as? VideoMessage, let url = message.videoUrl {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer!.frame = imageMessageView.bounds
            imageMessageView.layer.addSublayer(playerLayer!)
        }
        
        imageMessageView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: imageMessageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: imageMessageView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        initialVideoMessageFrame = playerLayer?.frame
    }
    
    @objc public func handleImageTap() {
        if let player = player, let layer = playerLayer {
            controllerDelegate?.imageMessageTapped(imageMessageView, layer, player)
        } else {
            controllerDelegate?.imageMessageTapped(imageMessageView, nil, nil)
        }
    }
    
    @objc private func handleVideoPlayPause() {
        if let playerLayer = playerLayer {
            controllerDelegate?.playVideoMessage(messagePlayerLayer: playerLayer, imageMessageView: imageMessageView, playButton: playButton, frame: initialVideoMessageFrame!)
        }
    }
    
}
