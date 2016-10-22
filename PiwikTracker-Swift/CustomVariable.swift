//
//  CustomVariable.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

@objc public enum CustomVariableScope: Int {
    case Visit
    case Screen
}

class CustomVariable {
    let index: UInt
    let name: String
    let value: String
    let scope: CustomVariableScope
    
    init(index: UInt, name: String, value: String, scope: CustomVariableScope) {
        self.index = index
        self.name = name
        self.value = value
        self.scope = scope
    }
}
