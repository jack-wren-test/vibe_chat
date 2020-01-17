//
//  DateHeaderLabel.swift
//  VibeChat
//
//  Created by Jack Smith on 10/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

/// Class for a date label to be used in CollectionView header.
class DateHeaderLabel: UILabel {

    // MARK:- Properties
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 14
        self.layer.cornerRadius = height / 2
        return CGSize(width: originalContentSize.width + 16, height: height)
    }
    
    var date: Date? {
        didSet {
            self.configureView()
        }
    }
    
    // MARK:- Methods
    
    private func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "decoration")
        self.text = self.formatDate()
        self.textColor = UIColor(named: "background")
        self.textAlignment = .center
        self.font = .systemFont(ofSize: 14, weight: .light)
        
    }
    
    private func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let date = date {
            let text = dateFormatter.string(from: date)
            return text
        }
        return dateFormatter.string(from: Date())
    }

}

