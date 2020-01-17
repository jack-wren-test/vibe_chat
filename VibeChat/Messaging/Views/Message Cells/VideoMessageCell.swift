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
final class VideoMessageCell: ImageMessageCell {
    
    // MARK:- Properties
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleVideoPlayPause), for: .touchUpInside)
        return button
    }()
    
    private(set) var playerLayer: AVPlayerLayer?
    private(set) var player: AVPlayer?
    private(set) var initialVideoMessageFrame: CGRect?
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.playerLayer?.removeFromSuperlayer()
    }
    
    // MARK:- Methods
    
    private func setupVideoLayer() {
        guard let imageMessageView = self.imageMessageView else {return}
        guard let message = self.message as? VideoMessage, let url = message.videoUrl else {return}
        self.player = AVPlayer(url: url)
        self.playerLayer = AVPlayerLayer(player: self.player!)
        self.playerLayer!.frame = imageMessageView.bounds
        imageMessageView.layer.addSublayer(self.playerLayer!)
    
        imageMessageView.addSubview(playButton)
        let playButtonSize: CGFloat = 75
        self.playButton.centerXAnchor.constraint(equalTo: imageMessageView.centerXAnchor).isActive = true
        self.playButton.centerYAnchor.constraint(equalTo: imageMessageView.centerYAnchor).isActive = true
        self.playButton.heightAnchor.constraint(equalToConstant: playButtonSize).isActive = true
        self.playButton.widthAnchor.constraint(equalToConstant: playButtonSize).isActive = true
        
        self.initialVideoMessageFrame = self.playerLayer?.frame
    }
    
    override func setupMessage() {
        super.setupMessage()
        self.setupVideoLayer()
    }
    
    @objc override func handleImageTap() {
        guard let player = self.player,
              let imageMessageView = self.imageMessageView,
              let layer = self.playerLayer else {return}
        self.controllerDelegate?.imageMessageTapped(imageMessageView, layer, player)
    }
    
    @objc private func handleVideoPlayPause() {
        guard let playerLayer = self.playerLayer,
              let imageMessageView = self.imageMessageView,
              let initialVideoMessageFrame = self.initialVideoMessageFrame else {return}
        self.controllerDelegate?.playVideoMessage(messagePlayerLayer: playerLayer,
                                                  imageMessageView: imageMessageView,
                                                  playButton: self.playButton,
                                                  frame: initialVideoMessageFrame)
    }
    
}
