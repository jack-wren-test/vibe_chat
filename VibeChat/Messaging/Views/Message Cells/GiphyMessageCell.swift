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
class GiphyMessageCell : MessageCell {
    
    // MARK:- Properties
    
    var giphyMessage: GiphyMessage? {
        didSet {
            guard let giphyMessage = giphyMessage else {return}
            guard let user = CurrentUser.shared.data else {return}
            let isOutgoingMessage = giphyMessage.fromUid == user.uid
            GiphyManager.shared.requestGif(withId: giphyMessage.giphId!) { (media) in
                if let media = media {
                    self.giphyMediaView.setMedia(media)
                    self.layoutMessage(isOutgoingMessage)
                    self.updateHeightAnchor(usingAspectRatio: giphyMessage.aspectRatio)
                }
            }
        }
    }
    
    let giphyMediaView : GPHMediaView = {
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
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        giphyMediaView.image = nil
        giphyMessage = nil
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        addSubview(giphyMediaView)
        
        incomingXConstraint = giphyMediaView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        outgoingXConstraint = giphyMediaView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        
        giphyMediaView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        giphyMediaView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        giphyMediaView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    private func updateHeightAnchor(usingAspectRatio: CGFloat) {
        viewHeightAnchor = heightAnchor.constraint(equalToConstant: 200/usingAspectRatio)
        viewHeightAnchor?.priority = UILayoutPriority.required
        viewHeightAnchor?.isActive = true
    }
    
}
