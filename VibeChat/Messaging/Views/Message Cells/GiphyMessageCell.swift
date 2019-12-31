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
                    self.setAspectRatio(media.aspectRatio)
                    self.layoutMessage(isOutgoingMessage)
                }
            }
        }
    }
    
    let giphyMediaView : GPHMediaView = {
        let view = GPHMediaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    // MARK:- Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        giphyMessage = nil
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        addSubview(giphyMediaView)
        
        incomingXConstraint = giphyMediaView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        outgoingXConstraint = giphyMediaView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        
        giphyMediaView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        giphyMediaView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        giphyMediaView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        heightAnchor.constraint(equalToConstant: 254).isActive = true
    }
    
    private func setAspectRatio(_ aspectRatio: CGFloat) {
//        heightAnchor.constraint(equalToConstant: (250/aspectRatio)+4).isActive = true
    }
    
}
