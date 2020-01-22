//
//  VideoView.swift
//  VibeChat
//
//  Created by Jack Smith on 21/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

struct VideoModel {
    var videoUrl:       URL
    var thumbnailUrl:   URL
}

enum VideoState {
    case playing, paused
}

final class VideoView: UIView {

    // MARK:- Properties
    
    private let thumbnailImageView = UIImageView()
    private let playerLayer = AVPlayerLayer()
    private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    private var player: AVPlayer!
    private var state: VideoState = .paused
    weak    var delegate: ExpandingMediaMessageDelegate?
    
    lazy var playButton: UIButton = {
        let playButton = UIButton(type: .system)
        playButton.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        playButton.tintColor = .white
        playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        return playButton
    }()
    
    lazy var pauseButton: UIButton = {
        let pauseButton = UIButton(type: .system)
        pauseButton.setImage(#imageLiteral(resourceName: "pauseIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        pauseButton.tintColor = .white
        pauseButton.addTarget(self, action: #selector(self.pauseButtonPressed), for: .touchUpInside)
        pauseButton.isHidden = true
        return pauseButton
    }()
    
    var videoModel: VideoModel? {
        didSet {
            self.setupVideo()
        }
    }
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutViews()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying),
        name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.player.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    // MARK:- Methods
    
    public func intteruptVideo() {
        self.player.pause()
        self.playerLayer.removeFromSuperlayer()
    }
    
    private func setupVideo() {
        guard let videoModel = self.videoModel else {return}
        self.thumbnailImageView.loadImageUsingCacheOrUrl(url: videoModel.thumbnailUrl)
        self.player = AVPlayer(url: videoModel.videoUrl)
        self.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    
    private func layoutViews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.addSubview(self.thumbnailImageView)
        self.thumbnailImageView.constraintsEqual(toView: self)
        
        self.addSubview(self.activityIndicator)
        self.activityIndicator.anchor(centerX: self.centerXAnchor, centerY: self.centerYAnchor, size: .init(width: 75, height: 75))
        self.activityIndicator.isHidden = true

        self.addSubview(self.playButton)
        self.playButton.anchor(centerX: self.centerXAnchor, centerY: self.centerYAnchor, size: .init(width: 75, height: 75))

        self.addSubview(self.pauseButton)
        self.pauseButton.anchor(top: topAnchor, bottom: nil,
                                leading: leadingAnchor, trailing: nil,
                                padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                                size: .init(width: 36, height: 36))
    }
    
    @objc private func viewTapped() {
        self.delegate?.expand(self)
    }
    
    @objc private func playButtonPressed() {
        self.addLayerIfNessesary()
        self.player.play()
        self.toggleControls(isPlaying: true)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    @objc private func pauseButtonPressed() {
        self.player.pause()
        self.toggleControls(isPlaying: false)
    }
    
    @objc private func didFinishPlaying() {
        if let player = self.player {
            player.seek(to: CMTime.zero)
            playButton.isHidden = false
            self.bringSubviewToFront(self.playButton)
            pauseButton.isHidden = true
        }
    }
    
    private func addLayerIfNessesary() {
        if self.playerLayer.superlayer != self.layer {
            self.layer.addSublayer(self.playerLayer)
            self.playerLayer.player = self.player
            playerLayer.frame = bounds
        }
    }
    
    private func toggleControls(isPlaying: Bool) {
        if isPlaying {
            self.playButton.isHidden = true
            self.pauseButton.isHidden = false
            self.bringSubviewToFront(self.pauseButton)
        } else {
            self.playButton.isHidden = false
            self.pauseButton.isHidden = true
            self.bringSubviewToFront(self.playButton)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if let player = self.player, player.timeControlStatus == .playing {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }

}
