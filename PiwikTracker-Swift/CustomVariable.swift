//
//  CustomVariable.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

class CustomVariable {
    let index: UInt
    let name: String
    let value: String
    
    init(index: UInt, name: String, value: String) {
        self.index = index
        self.name = name
        self.value = value
    }
}
