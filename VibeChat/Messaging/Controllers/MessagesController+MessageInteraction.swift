//
//  MessagesController+MessageInteraction.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController: messagesControllerDelegate {
    
    func imageMessageTapped(_ imageView: UIImageView) {
        
        // TODO: Zoom video layer too?
        
        startingImageView = imageView
        startingImageView?.isHidden = true
        imageStartingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: imageStartingFrame!)
        zoomingImageView.image = imageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        if let keywindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) {
            backgroundView = UIView(frame: keywindow.frame)
            backgroundView!.backgroundColor = UIColor(named: "background")
            backgroundView!.alpha = 0
            keywindow.addSubview(backgroundView!)
            keywindow.addSubview(zoomingImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView!.alpha = 1
                let height = self.imageStartingFrame!.height / self.imageStartingFrame!.width * keywindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
                zoomingImageView.center = keywindow.center
            }, completion: nil)
        }
    }
    
    @objc fileprivate func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 10
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.imageStartingFrame!
                self.backgroundView?.alpha = 0
            }) { (completed: Bool) in
                self.startingImageView?.isHidden = false
                zoomOutImageView.removeFromSuperview()
                self.backgroundView = nil
            }
        }
    }
    
}
