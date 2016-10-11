//
//  PiwikUserDefaults.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 11.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

extension UserDefaults {
    internal func set(date: Date, forKey key: String) {
        let timestamp = date.timeIntervalSince1970
        UserDefaults.standard.set(timestamp, forKey: key)
    }
    internal func date(forKey key: String) -> Date? {
        guard object(forKey: key) != nil else { return nil }
        let storedDouble = double(forKey: key)
        return Date(timeIntervalSince1970: storedDouble)
    }
}

class PiwikUserDefaults {
    internal static let standard = PiwikUserDefaults()
    
    internal var totalNumberOfVisits: UInt32 {
        get {
            return UInt32(UserDefaults.standard.integer(forKey: PiwikConstants.UserDefaultTotalNumberOfVisitsKey))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PiwikConstants.UserDefaultTotalNumberOfVisitsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    internal var firstVisit: Date {
        get {
            if let storedDate = UserDefaults.standard.date(forKey: PiwikConstants.UserDefaultFirstVistsTimestampKey) {
                return storedDate
            }
            let now = Date()
            UserDefaults.standard.set(now, forKey: PiwikConstants.UserDefaultFirstVistsTimestampKey)
            UserDefaults.standard.synchronize()
            return now
        }
    }
    
    internal var previousVisit: Date? {
        get {
            return UserDefaults.standard.date(forKey: PiwikConstants.UserDefaultPreviousVistsTimestampKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PiwikConstants.UserDefaultPreviousVistsTimestampKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    internal var currentVisit: Date? {
        get {
            return UserDefaults.standard.date(forKey: PiwikConstants.UserDefaultCurrentVisitTimestampKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PiwikConstants.UserDefaultCurrentVisitTimestampKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    internal var optOut: Bool {
        get {
            return UserDefaults.standard.bool(forKey: PiwikConstants.UserDefaultOptOutKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PiwikConstants.UserDefaultOptOutKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    internal func clientId(withKeyPrefix keyPrefix: String) -> String {
        let key = "\(keyPrefix)\(PiwikConstants.UserDefaultVisitorIDKey)"
        if let storedId = UserDefaults.standard.string(forKey: key) {
            return storedId
        }
        // none found, generate a key
        let uuid: String = UUID().uuidString.md5
        let clientID = uuid.substring(length: 16)
        UserDefaults.standard.setValue(clientID, forKey: key)
        UserDefaults.standard.synchronize()
        return clientID
    }
    
}
