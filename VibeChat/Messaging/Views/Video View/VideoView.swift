//
//  VideoView.swift
//  VibeChat
//
//  Created by Jack Smith on 21/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoView: UIView {

    // MARK:- Properties
    
    let thumbnailImageView = UIImageView()
    private let playerLayer = AVPlayerLayer()
    private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    private let playButton = UIButton(type: .system)
    private let pauseButton = UIButton(type: .system)
    
    private var player: AVPlayer?
    weak var delegate: ExpandingMediaMessageDelegate?
    
    var videoModel: VideoModel? {
        didSet {
            self.setupVideo()
        }
    }
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutViews()
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Methods
    
    public func intteruptVideo() {
        player?.pause()
        playerLayer.removeFromSuperlayer()
    }
    
    private func setupVideo() {
        guard let videoModel = videoModel else {return}
        thumbnailImageView.loadImageUsingCacheOrUrl(url: videoModel.thumbnailUrl)
        self.player = AVPlayer(url: videoModel.videoUrl)
        self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    
    private func layoutViews() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.addSubview(self.thumbnailImageView)
        self.thumbnailImageView.constraintsEqual(toView: self)
        
        self.addSubview(self.activityIndicator)
        self.activityIndicator.anchor(centerX: centerXAnchor, centerY: centerYAnchor, size: .init(width: 75, height: 75))
        self.activityIndicator.isHidden = true

        self.addSubview(self.playButton)
        self.playButton.anchor(centerX: centerXAnchor, centerY: centerYAnchor, size: .init(width: 75, height: 75))
        self.playButton.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        self.playButton.tintColor = .white
        self.playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)

        self.addSubview(self.pauseButton)
        self.pauseButton.anchor(top: topAnchor, bottom: nil,
                                leading: leadingAnchor, trailing: nil,
                                padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                                size: .init(width: 36, height: 36))
        self.pauseButton.setImage(#imageLiteral(resourceName: "pauseIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        self.pauseButton.tintColor = .white
        self.pauseButton.addTarget(self, action: #selector(self.pauseButtonPressed), for: .touchUpInside)
        self.pauseButton.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func viewTapped() {
        self.delegate?.expand(self)
    }
    
    @objc private func playButtonPressed() {
        // Create enum states for this?
        
        self.layer.addSublayer(self.playerLayer)
        self.playerLayer.player = player
        playerLayer.frame = bounds
        self.playButton.isHidden = true
        self.pauseButton.isHidden = false
        self.bringSubviewToFront(self.pauseButton)
        self.player?.play()
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    @objc private func pauseButtonPressed() {
        self.playButton.isHidden = false
        self.bringSubviewToFront(self.playButton)
        self.pauseButton.isHidden = true
        self.player?.pause()
    }
    
    @objc private func didFinishPlaying() {
        if let player = self.player {
            player.seek(to: CMTime.zero)
            playButton.isHidden = false
            self.bringSubviewToFront(self.playButton)
            pauseButton.isHidden = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if let player = player, player.timeControlStatus == .playing {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    public func hidePlayButton() {
        self.playButton.isHidden = true
    }
    
    public func showPlayButton() {
        self.playButton.isHidden = false
    }

}

struct VideoModel {
    var videoUrl:       URL
    var thumbnailUrl:   URL
}
