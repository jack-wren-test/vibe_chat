//
//  MessagesController+ImageMessageInteraction.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

/// Protocol to delegate image message interactions to MessagesController
protocol ImageInteractionDelegate: AnyObject {
    func imageMessageTapped(_ imageView: UIImageView, _ videoLayer: AVPlayerLayer?, _ videoPlayer: AVPlayer?)
    func playVideoMessage(messagePlayerLayer: AVPlayerLayer, imageMessageView: UIImageView, playButton: UIButton, frame: CGRect)
}

/// Needs a big refactor, currently very messy, add new class for expanding image and video player views.
// TODO:- Work on video playback, very buggy.
//extension MessagesController: {
//
//    func imageMessageTapped(_ imageView: UIImageView, _ videoLayer: AVPlayerLayer?, _ videoPlayer: AVPlayer?) {
//
//        var isVideoMessage = false
//
//        if  videoPlayer != nil, videoLayer != nil {
//            self.playerLayer = videoLayer
//            self.player = videoPlayer
//            self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
//            self.playButton = UIButton(type: .system)
//            isVideoMessage = true
//        }
//
//        if !isVideoMessage || isVideoMessage && player?.currentTime() == CMTime.zero {
//            self.imageStartingFrame = imageView.superview?.convert(imageView.frame, to: nil)
//
//            guard let imageStartingFrame = imageStartingFrame else {return}
//            self.zoomingImageView = UIImageView(frame: imageStartingFrame)
//            self.zoomingImageView?.image = imageView.image
//            self.zoomingImageView?.isUserInteractionEnabled = true
//            self.zoomingImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
//
//            self.animateZoomIn(isVideoMessage) { (_) in
//                if let zoomingImageView = self.zoomingImageView,
//                    let playerLayer = self.playerLayer,
//                    let playButton = self.playButton {
//                    self.addVideoPlayerCompnents(playerLayer, zoomingImageView, playButton)
//                }
//            }
//        }
//    }
//
//    fileprivate func animateZoomIn(_ isVideoMessage: Bool, completion: ((Bool)->())?) {
//        if let keywindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) {
//            self.backgroundView = UIView(frame: keywindow.frame)
//            self.backgroundView!.backgroundColor = UIColor(named: "background")
//            self.backgroundView!.alpha = 0
//
//            keywindow.addSubview(backgroundView!)
//            keywindow.addSubview(zoomingImageView!)
//
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.backgroundView!.alpha = 1
//                let height = !isVideoMessage ? self.imageStartingFrame!.height / self.imageStartingFrame!.width * keywindow.frame.width : keywindow.frame.height
//                self.zoomingImageView?.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
//                self.zoomingImageView?.center = keywindow.center
//            }, completion: completion)
//        }
//    }
//
//    fileprivate func addVideoPlayerCompnents(_ playerLayer: AVPlayerLayer, _ zoomingImageView: UIImageView,_ playButton: UIButton) {
//        playerLayer.frame = zoomingImageView.frame
//        zoomingImageView.addSubview(playButton)
//
//        playButton.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
//        playButton.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
//        playButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
//        playButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
//
//        playButton.setImage(#imageLiteral(resourceName: "playIcon").withRenderingMode(.alwaysTemplate), for: .normal)
//        playButton.tintColor = .white
//        playButton.translatesAutoresizingMaskIntoConstraints = false
//        playButton.addTarget(self, action: #selector(self.playFullscreenMedia), for: .touchUpInside)
//    }
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "timeControlStatus" {
//            if let player = player, player.timeControlStatus == .playing {
//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.removeFromSuperview()
//                self.playerLayer?.opacity = 1
//            }
//        }
//    }
//
//    func playVideoMessage(messagePlayerLayer: AVPlayerLayer, imageMessageView: UIImageView, playButton: UIButton, frame: CGRect) {
//        messagePlayerLayer.frame = frame
//        self.initialMediaMessageFrame = frame
//
//        self.zoomingImageView = imageMessageView
//        self.zoomingImageView?.contentMode = .scaleAspectFill
//        self.zoomingImageView?.layer.addSublayer(messagePlayerLayer)
//        self.zoomingImageView?.addSubview(activityIndicator)
//
//        self.playButton = playButton
//        self.player = messagePlayerLayer.player
//
//        self.activityIndicator.centerXAnchor.constraint(equalTo: zoomingImageView!.centerXAnchor).isActive = true
//        self.activityIndicator.centerYAnchor.constraint(equalTo: zoomingImageView!.centerYAnchor).isActive = true
//
//        if let player = self.player {
//            self.playerLayer = messagePlayerLayer
//            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
//            player.play()
//            playButton.isHidden = true
//            self.activityIndicator.startAnimating()
//        }
//    }
//
//    @objc func playFullscreenMedia() {
//        if let player = player, let playerLayer = self.playerLayer, let zoomingImageView = self.zoomingImageView, let playButton = self.playButton {
//            zoomingImageView.layer.addSublayer(playerLayer)
//            zoomingImageView.addSubview(activityIndicator)
//
//            self.activityIndicator.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
//            self.activityIndicator.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
//
//            player.play()
//            playButton.isHidden = true
//            self.activityIndicator.startAnimating()
//        }
//    }
//
//    @objc func didFinishPlaying() {
//        if let playButton = self.playButton, let player = self.player {
//            player.seek(to: CMTime.zero)
//            playButton.isHidden = false
//            self.zoomingImageView?.bringSubviewToFront(playButton)
//            self.playerLayer?.opacity = 0
//            self.playerLayer?.removeFromSuperlayer()
//        }
//    }
//
//    private func zoomOut(_ tapGesture: UITapGestureRecognizer) {
//        if let zoomOutImageView = tapGesture.view {
//            zoomOutImageView.layer.cornerRadius = 10
//            zoomOutImageView.clipsToBounds = true
//            self.playButton?.removeFromSuperview()
//            self.playButton = nil
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                zoomOutImageView.frame = self.imageStartingFrame!
//                self.backgroundView?.alpha = 0
//                self.playerLayer?.opacity = 0
//            }) { (completed: Bool) in
//                if let frame = self.initialMediaMessageFrame {
//                    self.playerLayer?.frame = frame
//                }
//                zoomOutImageView.removeFromSuperview()
//                self.backgroundView = nil
//            }
//        }
//    }
//
//    @objc private func handleZoomOut(tapGesture: UITapGestureRecognizer) {
//        if player == nil {
//            zoomOut(tapGesture)
//        } else if let player = self.player, player.currentTime() == CMTime.zero {
//            zoomOut(tapGesture)
//        }
//    }
    
//}
