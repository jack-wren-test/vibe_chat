//
//  File.swift
//  VibeChatTests
//
//  Created by Jack Smith on 13/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    public func waitForExpectation(_ timeout: Double) {
        waitForExpectations(timeout: timeout) { (error) in
            guard let error = error else {return}
            print("Spent too long waiting for expectations: \(error.localizedDescription)")
        }
    }
    
}
