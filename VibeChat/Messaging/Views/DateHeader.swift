//
//  DateHeader.swift
//  VibeChat
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class DateHeader: UILabel {

    // MARK:- Properties
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 14
        layer.cornerRadius = height / 2
        return CGSize(width: originalContentSize.width + 16, height: height)
    }
    
    var date: Date? {
        didSet {
            configureView()
        }
    }
    
    // MARK:- Methods
    
    fileprivate func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        backgroundColor = UIColor(named: "decoration")
        text = formatDate()
        textColor = UIColor(named: "background")
        textAlignment = .center
        font = .systemFont(ofSize: 14, weight: .light)
    }
    
    fileprivate func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let date = date {
            let text = dateFormatter.string(from: date)
            return text
        }
        return dateFormatter.string(from: Date())
    }

}
