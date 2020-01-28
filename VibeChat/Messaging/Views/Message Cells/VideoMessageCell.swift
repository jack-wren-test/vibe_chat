//
//  VideoMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 09/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import AVFoundation

/// Class for a video message cell.
final class VideoMessageCell: MessageCell {
    
    // MARK:- Properties
    
    private(set) var videoView: VideoView?
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        guard let message = message as? VideoMessage else {return}
        self.updateHeightAnchor(usingAspectRatio: message.aspectRatio)
    }
    
    override func prepareForReuse() {
        self.videoView = nil
    }
    
    // MARK:- Methods
    
    override func setupMessage() {
        super.setupMessage()
        self.setupVideoView()
    }
    
    private func setupVideoView() {
        guard let message = message as? VideoMessage,
              let videoModel = message.toVideoModel() else {return}
        self.videoView?.videoModel = videoModel
    }
    
    private func configureViews() {
        
        videoView = VideoView()
        guard let videoView = self.videoView else {return}
        self.addSubview(videoView)
        
        
        videoView.anchor(top: self.topAnchor, bottom: self.bottomAnchor,
                         leading: nil, trailing: nil,
                         padding: .init(top: self.cellBuffer, left: self.cellBuffer, bottom: 0, right: 0),
                         size: nil)
        videoView.widthAnchor.constraint(equalToConstant: self.maxMessageWidth).isActive = true
        
        self.incomingXConstraint = videoView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                                             constant: self.edgeBuffer)
        self.outgoingXConstraint = videoView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                                              constant: -self.edgeBuffer)
    }
    
    override func addTapGesture() {
        super.addTapGesture()
        guard let pan = self.panGesture else {return}
        self.videoView!.addGestureRecognizer(pan)
    }
    
}
