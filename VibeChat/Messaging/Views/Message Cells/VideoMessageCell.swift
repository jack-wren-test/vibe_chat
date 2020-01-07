//
//  VideoMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 31/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class VideoMessageCell: ImageMessageCell {
    
    // MARK:- Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        playerLayer?.removeFromSuperlayer()
    }
    
}
