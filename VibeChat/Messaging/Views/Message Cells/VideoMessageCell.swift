//
//  VideoMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 31/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class VideoMessageCell: ImageMessageCell {
    
    // MARK:- Properties
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleVideoPlayPause), for: .touchUpInside)
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK:- Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        playerLayer?.removeFromSuperlayer()
        activityIndicator.stopAnimating()
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        imageMessageView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: imageMessageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: imageMessageView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        imageMessageView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: imageMessageView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: imageMessageView.centerYAnchor).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 75).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    @objc private func handleVideoPlayPause() {
        if player != nil {
            player?.play()
            playButton.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    
}

