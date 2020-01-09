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
    func playVideoMessage(messagePlayerLayer: AVPlayerLayer, imageMessageView: UIImageView, playButton: UIButton, frame: CGRect)
}

extension MessagesController: ImageMessageDelegate {
    
    func imageMessageTapped(_ imageView: UIImageView, _ videoLayer: AVPlayerLayer?, _ videoPlayer: AVPlayer?) {
        
        var isVideoMessage = false
        
        if  videoPlayer != nil, videoLayer != nil {
            playerLayer = videoLayer
            player = videoPlayer
            player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            playButton = UIButton(type: .system)
            isVideoMessage = true
        }
        
        if !isVideoMessage || isVideoMessage, player?.currentTime() == CMTime.zero {
            imageStartingFrame = imageView.superview?.convert(imageView.frame, to: nil)
            
            zoomingImageView = UIImageView(frame: imageStartingFrame!)
            zoomingImageView?.image = imageView.image
            zoomingImageView?.isUserInteractionEnabled = true
            zoomingImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            animateZoomIn { (_) in
                if let zoomingImageView = self.zoomingImageView, let playerLayer = self.playerLayer, let playButton = self.playButton {
                    self.addVideoPlayerCompnents(playerLayer, zoomingImageView, playButton)
                }
            }
        }
    }
    
    fileprivate func animateZoomIn(completion: ((Bool)->())?) {
        if let keywindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) {
            
            backgroundView = UIView(frame: keywindow.frame)
            backgroundView!.backgroundColor = UIColor(named: "background")
            backgroundView!.alpha = 0
            
            keywindow.addSubview(backgroundView!)
            keywindow.addSubview(zoomingImageView!)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView!.alpha = 1
                let height = self.imageStartingFrame!.height / self.imageStartingFrame!.width * keywindow.frame.width
                self.zoomingImageView?.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
                self.zoomingImageView?.center = keywindow.center
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
                playerLayer?.opacity = 1
            }
        }
    }
    
    func playVideoMessage(messagePlayerLayer: AVPlayerLayer, imageMessageView: UIImageView, playButton: UIButton, frame: CGRect) {
        
        print("frame: \(frame)")
        messagePlayerLayer.frame = frame
        initialVideoMessageFrame = frame
        
        zoomingImageView = imageMessageView
        zoomingImageView?.contentMode = .scaleAspectFill
        zoomingImageView?.layer.addSublayer(messagePlayerLayer)
        zoomingImageView?.addSubview(activityIndicator)
        
        self.playButton = playButton
        self.player = messagePlayerLayer.player
        
        activityIndicator.centerXAnchor.constraint(equalTo: zoomingImageView!.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: zoomingImageView!.centerYAnchor).isActive = true
        
        if let player = self.player {
            playerLayer = messagePlayerLayer
            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            player.play()
            playButton.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    @objc func playFullscreenMedia() {
        if let player = player, let playerLayer = self.playerLayer, let zoomingImageView = self.zoomingImageView, let playButton = self.playButton {
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
            zoomingImageView?.bringSubviewToFront(playButton)
            self.playerLayer?.opacity = 0
            playerLayer?.removeFromSuperlayer()
        }
    }
    
    fileprivate func zoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 10
            zoomOutImageView.clipsToBounds = true
            playButton?.removeFromSuperview()
            playButton = nil
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.imageStartingFrame!
                self.backgroundView?.alpha = 0
                self.playerLayer?.opacity = 0
            }) { (completed: Bool) in
                if let frame = self.initialVideoMessageFrame {
                    self.playerLayer?.frame = frame
                }
                zoomOutImageView.removeFromSuperview()
                self.backgroundView = nil
            }
        }
    }
    
    @objc fileprivate func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if player == nil {
            zoomOut(tapGesture)
        } else if let player = self.player, player.currentTime() == CMTime.zero {
            zoomOut(tapGesture)
        }
    }
    
}
