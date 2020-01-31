//
//  ReactButton.swift
//  VibeChat
//
//  Created by Jack Smith on 31/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

class ReactButton: UIButton {
    
    // MARK:- Properties
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layoutViews()
    }
    
    // MARK:- Methods
    
    private func layoutViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle("😅", for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 35)
    }
    
}
