//
//  MessagesController+Video.swift
//  VibeChat
//
//  Created by Jack Smith on 21/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

protocol ExpandingMediaMessageDelegate: AnyObject {
    func expand(_ view: UIView)
}

extension MessagesController: ExpandingMediaMessageDelegate {
    
    func expand(_ view: UIView) {
        self.setupBackgroundView()
        self.zoomingView = self.setupZoomingView(view)
        self.animateZoomIn(completion: nil)
    }
    
    private func setupBackgroundView() {
        guard let keywindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {return}
        self.backgroundView = UIView(frame: keywindow.frame)
        guard let backgroundView = self.backgroundView else {return}
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        keywindow.addSubview(backgroundView)
    }
    
    private func setupZoomingView(_ view: UIView) -> UIView {
        var zoomingView: UIView
        guard let initialFrame = view.superview?.convert(view.frame, to: nil) else {return UIView()}
        self.initialMediaMessageFrame = initialFrame
        if let videoView = view as? VideoView {
            let zoomingVideoView = VideoView()
            zoomingVideoView.videoModel = videoView.videoModel
            zoomingView = zoomingVideoView
        } else {
            let imageView = view as! UIImageView
            let zoomingImageView = UIImageView()
            zoomingImageView.clipsToBounds = true
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.image = imageView.image
            zoomingView = zoomingImageView
        }
        zoomingView.frame = initialFrame
        zoomingView.layer.cornerRadius = 0
        zoomingView.layoutIfNeeded()
        zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        let keywindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
        keywindow?.addSubview(zoomingView)
        return zoomingView
    }
    
    private func animateZoomIn(completion: ((Bool)->Void)?) {
        guard let zoomingView = self.zoomingView,
              let keywindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow}),
              let backgroundView = self.backgroundView else {return}
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            backgroundView.alpha = 1
            let height = (zoomingView.frame.height / zoomingView.frame.width * keywindow.frame.width)
            self.zoomingView?.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
            self.zoomingView?.center = keywindow.center
            self.zoomingView?.layoutIfNeeded()
        }, completion: completion)
    }
    
    @objc private func handleZoomOut() {
        if let zoomingView = self.zoomingView as? VideoView {
                zoomingView.intteruptVideo()
                self.animateZoomOut()
            } else {
                self.animateZoomOut()
            }
        }
    
    private func animateZoomOut() {
        guard let initialFrame = self.initialMediaMessageFrame else {return}
        self.zoomingView?.layer.cornerRadius = 10
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.zoomingView?.frame = initialFrame
            self.zoomingView?.layoutIfNeeded()
            self.backgroundView?.alpha = 0
        }) { (_) in
            self.zoomingView?.removeFromSuperview()
            self.zoomingView = nil
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
        }
    }
    
}
