//
//  MessagesController+MessageInteraction.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

extension MessagesController: messagesControllerDelegate {
    
    func imageMessageTapped(_ imageView: UIImageView, _ videoLayer: AVPlayerLayer?, _ videoPlayer: AVPlayer?) {
        
        playerLayer = videoLayer
        player = videoPlayer
        
        startingImageView = imageView
        startingImageView?.isHidden = true
        
        imageStartingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        zoomingImageView = UIImageView(frame: imageStartingFrame!)
        zoomingImageView?.image = imageView.image
        zoomingImageView?.isUserInteractionEnabled = true
        zoomingImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        playButton = UIButton(type: .system)
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        
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
                self.playerLayer?.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
                self.zoomingImageView?.center = keywindow.center
            }) { (completed: Bool) in
                
                if let playerLayer = self.playerLayer, let activityIndicator = self.activityIndicator, let playButton = self.playButton, let zoomingImageView = self.zoomingImageView {
                    
                    // Move adding layer and activity indicator to play button pressed
                    // Observe when starts playing and revome activity indicator
                    // Observe when ends playing and make play button visible
                    // smooth out return animation
                    // refactor the shit out of it
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                    
                    zoomingImageView.addSubview(playButton)
                    zoomingImageView.addSubview(activityIndicator)
                    zoomingImageView.layer.addSublayer(playerLayer)
                    
                    activityIndicator.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
                    activityIndicator.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
                    activityIndicator.heightAnchor.constraint(equalToConstant: 75).isActive = true
                    activityIndicator.widthAnchor.constraint(equalToConstant: 75).isActive = true
                    
                    playButton.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
                    playButton.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
                    playButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
                    playButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
                    
                    playButton.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
                    playButton.tintColor = .white
                    playButton.translatesAutoresizingMaskIntoConstraints = false
                    playButton.addTarget(self, action: #selector(self.playMedia), for: .touchUpInside)
                    
                    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                }
                
            }
        }
    }
    
    @objc func playMedia() {
        if player != nil {
            player?.play()
            playButton?.isHidden = true
            activityIndicator?.startAnimating()
        }
    }
    
    @objc func didFinishPlaying() {
        playButton?.isHidden = false
    }
    
    @objc fileprivate func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 10
            zoomOutImageView.clipsToBounds = true
            
            self.playerLayer?.opacity = 0
            self.playButton?.removeFromSuperview()
            self.activityIndicator?.removeFromSuperview()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.imageStartingFrame!
                self.backgroundView?.alpha = 0
            }) { (completed: Bool) in
                self.player = nil
                self.playerLayer = nil
                self.startingImageView?.isHidden = false
                zoomOutImageView.removeFromSuperview()
                self.backgroundView = nil
            }
        }
    }
    
}
