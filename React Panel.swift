//
//  React Panel.swift
//  VibeChat
//
//  Created by Jack Smith on 31/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

class ReactPanel: UIView {
    
    // MARK:- Properties
    private let reuseId = ""
    private let collectionView = UICollectionView()
    
    var emojis = [
        "🚇", "🍑", "👨‍👨‍👧‍👧",
        "🚇", "🍑", "👨‍👨‍👧‍👧",
        "🚇", "🍑", "👨‍👨‍👧‍👧",
        "🚇", "🍑", "👨‍👨‍👧‍👧"
    ]
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- Methods
    
    private func layoutViews() {
        
    }
    
    private func collectoinViewConfig() {
        
    }
    
}

extension ReactPanel: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: <#T##String#>, for: indexPath) as! ReactionImageCell
        
    }
    
}

class ReactionImageCell: UICollectionViewCell {
    
    // MARK:- Properties
    
    private let label = UILabel()
    
    // MARK:- Lifecycle
    
    init(emoji: String) {
        super.init(frame: CGRect.zero)
        self.label.text = emoji
        self.layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Methods
    
    private func layoutViews() {
        label.font = .systemFont(ofSize: 35)
        self.addSubview(label)
        self.label.constraintsEqual(toView: self)
    }
    
}
