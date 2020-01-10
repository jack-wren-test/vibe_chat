//
//  DateHeader.swift
//  VibeChat
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Class for the date header used in the messages controller.
class DateHeader: UICollectionReusableView {
    
    // MARK:- Properties
    
    let dateLabel = DateHeaderLabel()
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Methods
    
    fileprivate func configureView() {
        addSubview(dateLabel)
        dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
