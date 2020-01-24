//
//  NoConversationsCoverView.swift
//  VibeChat
//
//  Created by Jack Smith on 13/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

/// Cover view for covering the empty table view in the home controller when no conversations exist.
final class NoConversationsCoverView: UIView {
    
    // MARK:- Properties
    
    private let imageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "sadFaceIcon"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UIColor(named: "text_alt")
        return view
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "You have no conversations yet. Tap the new conversations button (top right) to get started!"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textColor = UIColor(named: "text_alt")
        label.textAlignment = .center
        return label
    }()
    
    
    // MARK:- Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Methods
    
    fileprivate func layoutViews() {
        self.backgroundColor = UIColor(named: "whiteblack")
        
        self.imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [imageView, textLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
