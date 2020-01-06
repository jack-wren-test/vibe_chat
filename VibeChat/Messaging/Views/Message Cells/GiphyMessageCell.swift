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
    
    // MARK:- Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        giphyMessage = nil
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        addSubview(giphyMediaView)
        
        incomingXConstraint = giphyMediaView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        outgoingXConstraint = giphyMediaView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        
        giphyMediaView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        giphyMediaView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        giphyMediaView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    private func updateHeightAnchor(usingAspectRatio: CGFloat) {
        let viewHeightAnchor = heightAnchor.constraint(equalToConstant: 200/usingAspectRatio)
        viewHeightAnchor.priority = UILayoutPriority.required
        viewHeightAnchor.isActive = true
    }
    
}
