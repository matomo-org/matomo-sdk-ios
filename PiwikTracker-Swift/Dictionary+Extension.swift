//
//  Dictionary+Extension.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 11.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

protocol OptionalType {}

extension Optional: OptionalType {}

extension Dictionary {
    static func removeOptionals(dictionary: [Key: Value?]) -> [Key:Value] {
        var filtered: [Key:Value] = [:]
        for (k, v) in dictionary {
            if let value = v {
                filtered[k] = value
            }
        }
        return filtered
    }
}
