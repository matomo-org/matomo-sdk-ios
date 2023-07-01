import Foundation

/// MatomoUserDefaults is a wrapper for the UserDefaults with properties
/// mapping onto values stored in the UserDefaults.
/// All getter and setter are sideeffect free and automatically syncronize
/// after writing.
internal struct MatomoUserDefaults {
    let userDefaults: UserDefaults

    init(suiteName: String?) {
        userDefaults = UserDefaults(suiteName: suiteName)!
    }
    
    var totalNumberOfVisits: Int {
        get {
            return userDefaults.integer(forKey: MatomoUserDefaults.Key.totalNumberOfVisits.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.totalNumberOfVisits.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var firstVisit: Date? {
        get {
            return userDefaults.object(forKey: MatomoUserDefaults.Key.firstVistsTimestamp.rawValue) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.firstVistsTimestamp.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var previousVisit: Date? {
        get {
            return userDefaults.object(forKey: MatomoUserDefaults.Key.previousVistsTimestamp.rawValue) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.previousVistsTimestamp.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var currentVisit: Date? {
        get {
            return userDefaults.object(forKey: MatomoUserDefaults.Key.currentVisitTimestamp.rawValue) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.currentVisitTimestamp.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var optOut: Bool {
        get {
            return userDefaults.bool(forKey: MatomoUserDefaults.Key.optOut.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.optOut.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var clientId: String? {
        get {
            return userDefaults.string(forKey: MatomoUserDefaults.Key.clientID.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: MatomoUserDefaults.Key.clientID.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var forcedVisitorId: String? {
        get {
            return userDefaults.string(forKey: MatomoUserDefaults.Key.forcedVisitorID.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: MatomoUserDefaults.Key.forcedVisitorID.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var visitorUserId: String? {
        get {
            return userDefaults.string(forKey: MatomoUserDefaults.Key.visitorUserID.rawValue);
        }
        set {
            userDefaults.setValue(newValue, forKey: MatomoUserDefaults.Key.visitorUserID.rawValue);
            userDefaults.synchronize()
        }
    }
    
    var lastOrder: Date? {
        get {
            return userDefaults.object(forKey: MatomoUserDefaults.Key.lastOrder.rawValue) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.lastOrder.rawValue)
        }
    }
    
    func reset() {
        for key in Key.allCases {
            userDefaults.removeObject(forKey: key.rawValue)
        }
    }
}

extension MatomoUserDefaults {
    public mutating func copy(from userDefaults: UserDefaults) {
        totalNumberOfVisits = userDefaults.integer(forKey: MatomoUserDefaults.Key.totalNumberOfVisits.rawValue)
        firstVisit = userDefaults.object(forKey: MatomoUserDefaults.Key.firstVistsTimestamp.rawValue) as? Date
        previousVisit = userDefaults.object(forKey: MatomoUserDefaults.Key.previousVistsTimestamp.rawValue) as? Date
        currentVisit = userDefaults.object(forKey: MatomoUserDefaults.Key.currentVisitTimestamp.rawValue) as? Date
        optOut = userDefaults.bool(forKey: MatomoUserDefaults.Key.optOut.rawValue)
        clientId = userDefaults.string(forKey: MatomoUserDefaults.Key.clientID.rawValue)
        forcedVisitorId = userDefaults.string(forKey: MatomoUserDefaults.Key.forcedVisitorID.rawValue)
        visitorUserId = userDefaults.string(forKey: MatomoUserDefaults.Key.visitorUserID.rawValue)
        lastOrder = userDefaults.object(forKey: MatomoUserDefaults.Key.lastOrder.rawValue) as? Date
    }
}

extension MatomoUserDefaults {
    internal enum Key: String, CaseIterable {
        case totalNumberOfVisits = "PiwikTotalNumberOfVistsKey"
        case currentVisitTimestamp = "PiwikCurrentVisitTimestampKey"
        case previousVistsTimestamp = "PiwikPreviousVistsTimestampKey"
        case firstVistsTimestamp = "PiwikFirstVistsTimestampKey"
        
        // Note:    To be compatible with previous versions, the clientID key retains its old value,
        //          even though it is now a misnomer since adding visitorUserID makes it a bit confusing.
        case clientID = "PiwikVisitorIDKey"
        case forcedVisitorID = "PiwikForcedVisitorIDKey"
        case visitorUserID = "PiwikVisitorUserIDKey"
        case optOut = "PiwikOptOutKey"
        case lastOrder = "PiwikLastOrderDateKey"
    }
}
