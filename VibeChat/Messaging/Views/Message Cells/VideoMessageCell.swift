//
//  VideoMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 09/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

/// Class for a video message cell.
class VideoMessageCell: ImageMessageCell {
    
    // MARK:- Properties
    
    override var message: ImageMessage? {
        didSet {
            guard let message = message as? VideoMessage, let user = CurrentUser.shared.data, let url = message.imageUrl else {return}
            imageMessageView.loadImageUsingCacheOrUrl(url: url) { (image) in
                if image != nil {
                    let isOutgoingMessage = message.fromUid == user.uid
                    self.layoutMessage(isOutgoingMessage)
                    self.updateHeightAnchor(usingAspectRatio: message.aspectRatio)
                    self.setupVideoLayer()
                }
            }
        }
    }
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleVideoPlayPause), for: .touchUpInside)
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var initialVideoMessageFrame: CGRect?
    
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        playerLayer?.removeFromSuperlayer()
    }
    
    // MARK:- Methods
    
    fileprivate func setupVideoLayer() {
        if let message = message as? VideoMessage, let url = message.videoUrl {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer!.frame = imageMessageView.bounds
            imageMessageView.layer.addSublayer(playerLayer!)
        
            imageMessageView.addSubview(playButton)
            playButton.centerXAnchor.constraint(equalTo: imageMessageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: imageMessageView.centerYAnchor).isActive = true
            playButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
            
            initialVideoMessageFrame = playerLayer?.frame
        }
    }
    
    @objc override func handleImageTap() {
        if let player = player, let layer = playerLayer {
            controllerDelegate?.imageMessageTapped(imageMessageView, layer, player)
        }
    }
    
    @objc private func handleVideoPlayPause() {
        if let playerLayer = playerLayer {
            controllerDelegate?.playVideoMessage(messagePlayerLayer: playerLayer, imageMessageView: imageMessageView, playButton: playButton, frame: initialVideoMessageFrame!)
        }
    }
    
}
