//
//  MessageTimeLabel.swift
//  VibeChat
//
//  Created by Jack Smith on 28/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

class MessageTimeLabel: UILabel {
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Methods
    
    private func layoutViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = .lightGray
        self.font = .systemFont(ofSize: 10, weight: .light)
    }
    
}
