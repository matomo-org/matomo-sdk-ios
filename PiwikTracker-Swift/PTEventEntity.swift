//
//  PTEventEntity.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 07.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation
import CoreData

internal class PTEventEntity: NSManagedObject {
    public var date: Date?
    public var piwikRequestParameters: NSData?
    
    override func awakeFromInsert() {
        date = Date()
    }
}
