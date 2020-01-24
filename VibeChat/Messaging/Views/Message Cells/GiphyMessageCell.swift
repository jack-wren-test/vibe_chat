//
//  GiphMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import GiphyUISDK
import GiphyCoreSDK

/// Class for a gif based cell.
final class GiphyMessageCell : MessageCell {
    
    // MARK:- Properties
    
    fileprivate let giphyMediaView: GPHMediaView = {
        let view = GPHMediaView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        self.giphyMediaView.image = nil
    }
    
    override func didMoveToSuperview() {
        guard let message = message as? GiphyMessage else {return}
        self.updateHeightAnchor(usingAspectRatio: message.aspectRatio)
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        self.addSubview(giphyMediaView)
        self.incomingXConstraint = giphyMediaView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.edgeBuffer)
        self.outgoingXConstraint = giphyMediaView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.edgeBuffer)
        
        self.giphyMediaView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.cellBuffer).isActive = true
        self.giphyMediaView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.cellBuffer).isActive = true
        self.giphyMediaView.widthAnchor.constraint(equalToConstant: self.maxMessageWidth).isActive = true
    }
    
    override func setupMessage() {
        super.setupMessage()
        guard let giphyMessage = self.message as? GiphyMessage else {return}
        GiphyManager.shared.requestGif(withId: giphyMessage.giphId) { [weak self] media in
            guard let self = self, let media = media else {return}
            self.giphyMediaView.setMedia(media)
        }
    }
    
}
