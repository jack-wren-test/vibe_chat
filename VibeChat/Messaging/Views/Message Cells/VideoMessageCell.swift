//
//  VideoMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 31/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

class VideoMessageCell: MessageCell {
    
    // MARK:- Properties
    
    var videoMessage: VideoMessage? {
        didSet {
            guard let videoMessage = videoMessage else {return}
            guard let user = CurrentUser.shared.data else {return}
            guard let thumbnailUrl = videoMessage.thumbnailImageUrl else {return}
            thumbnailImageView.loadImageUsingCacheWithUrl(url: thumbnailUrl) { (image) in
                if let image = image {
                    let isOutgoingMessage = videoMessage.fromUid == user.uid
                    self.thumbnailImageView.image = image
                    self.layoutMessage(isOutgoingMessage)
                }
            }
        }
    }
    
    lazy var thumbnailImageView: UIImageView = {
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
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var controllerDelegate: messagesControllerDelegate?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    // MARK:- Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        videoMessage = nil
        playerLayer?.removeFromSuperlayer()
        activityIndicator.stopAnimating()
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        addSubview(thumbnailImageView)
        incomingXConstraint = thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        outgoingXConstraint = thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        
        thumbnailImageView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        thumbnailImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalToConstant: 9*16).isActive = true
        
        thumbnailImageView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        thumbnailImageView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 75).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        heightAnchor.constraint(equalToConstant: (16*16)+4).isActive = true
    }
    
    @objc private func handleImageTap() {
        controllerDelegate?.imageMessageTapped(thumbnailImageView)
    }
    
    @objc private func handleVideoPlayPause() {
        if let url = videoMessage?.videoUrl {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer!.frame = thumbnailImageView.bounds
            thumbnailImageView.layer.addSublayer(playerLayer!)
            player?.play()
            
            playButton.isHidden = true
            
            activityIndicator.startAnimating()
        }
    }
    
    
}

