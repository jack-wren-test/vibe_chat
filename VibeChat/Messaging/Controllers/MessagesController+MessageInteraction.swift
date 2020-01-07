//
//  MessagesController+MessageInteraction.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

protocol ImageMessageDelegate {
    func imageMessageTapped(_ imageView: UIImageView, _ videoLayer: AVPlayerLayer?, _ videoPlayer: AVPlayer?)
    func playVideoMessage(messagePlayerLayer: AVPlayerLayer, imageMessageView: UIImageView, playButton: UIButton)
}

extension MessagesController: ImageMessageDelegate {
    
    func imageMessageTapped(_ imageView: UIImageView, _ videoLayer: AVPlayerLayer?, _ videoPlayer: AVPlayer?) {
        
        playerLayer = videoLayer
        player = videoPlayer
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
//        startingImageView = imageView
//        startingImageView?.isHidden = true
        
        playButton = UIButton(type: .system)
        imageStartingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        
        videoContainerView = UIImageView(frame: imageStartingFrame!)
        videoContainerView?.image = imageView.image
        videoContainerView?.isUserInteractionEnabled = true
        videoContainerView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        animateZoomIn { (_) in
            if let zoomingImageView = self.videoContainerView, let playerLayer = self.playerLayer, let playButton = self.playButton {
                self.addVideoPlayerCompnents(playerLayer, zoomingImageView, playButton)
            }
        }
    }
    
    fileprivate func animateZoomIn(completion: ((Bool)->())?) {
        if let keywindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) {
            
            backgroundView = UIView(frame: keywindow.frame)
            backgroundView!.backgroundColor = UIColor(named: "background")
            backgroundView!.alpha = 0
            
            keywindow.addSubview(backgroundView!)
            keywindow.addSubview(videoContainerView!)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView!.alpha = 1
                let height = self.imageStartingFrame!.height / self.imageStartingFrame!.width * keywindow.frame.width
                self.videoContainerView?.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
                self.videoContainerView?.center = keywindow.center
            }, completion: completion)
        }
    }
    
    fileprivate func addVideoPlayerCompnents(_ playerLayer: AVPlayerLayer, _ zoomingImageView: UIImageView,_ playButton: UIButton) {
        playerLayer.frame = zoomingImageView.frame
        zoomingImageView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        playButton.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        playButton.tintColor = .white
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(self.playFullscreenMedia), for: .touchUpInside)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if let player = player, player.timeControlStatus == .playing {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    func playVideoMessage(messagePlayerLayer: AVPlayerLayer, imageMessageView: UIImageView, playButton: UIButton) {
        videoContainerView = imageMessageView
        videoContainerView?.layer.addSublayer(messagePlayerLayer)
        videoContainerView?.addSubview(activityIndicator)
        
        self.playButton = playButton
        self.player = messagePlayerLayer.player
        
        activityIndicator.centerXAnchor.constraint(equalTo: videoContainerView!.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: videoContainerView!.centerYAnchor).isActive = true
        
        if let player = self.player {
            playerLayer = messagePlayerLayer
            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            player.play()
            playButton.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    @objc func playFullscreenMedia() {
        if let player = player, let playerLayer = self.playerLayer, let zoomingImageView = self.videoContainerView, let playButton = self.playButton {
            zoomingImageView.layer.addSublayer(playerLayer)
            zoomingImageView.addSubview(activityIndicator)
            
            activityIndicator.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
            
            player.play()
            playButton.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    @objc func didFinishPlaying() {
        if let playButton = self.playButton, let player = self.player {
            player.seek(to: CMTime.zero)
            playButton.isHidden = false
            videoContainerView?.bringSubviewToFront(playButton)
        }
    }
    
    @objc fileprivate func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 10
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.imageStartingFrame!
                self.playerLayer?.frame = self.imageStartingFrame!
                self.backgroundView?.alpha = 0
            }) { (completed: Bool) in
//                self.startingImageView?.isHidden = false
                self.videoContainerView = nil
                zoomOutImageView.removeFromSuperview()
                self.playerLayer?.removeFromSuperlayer()
                self.backgroundView = nil
            }
        }
    }
    
}
