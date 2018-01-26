import Foundation

/// MatomoUserDefaults is a wrapper for the UserDefaults with properties
/// mapping onto values stored in the UserDefaults.
/// All getter and setter are sideeffect free and automatically syncronize
/// after writing.
internal struct MatomoUserDefaults {
    static var standard = MatomoUserDefaults()
    let userDefaults = UserDefaults.standard
    
    var totalNumberOfVisits: Int {
        get {
            return userDefaults.integer(forKey: MatomoUserDefaults.Key.totalNumberOfVisits)
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.totalNumberOfVisits)
            userDefaults.synchronize()
        }
    }
    
    var firstVisit: Date? {
        get {
            return userDefaults.object(forKey: MatomoUserDefaults.Key.firstVistsTimestamp) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.firstVistsTimestamp)
            userDefaults.synchronize()
        }
    }
    
    var previousVisit: Date? {
        get {
            return userDefaults.object(forKey: MatomoUserDefaults.Key.previousVistsTimestamp) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.previousVistsTimestamp)
            userDefaults.synchronize()
        }
    }
    
    var currentVisit: Date? {
        get {
            return userDefaults.object(forKey: MatomoUserDefaults.Key.currentVisitTimestamp) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.currentVisitTimestamp)
            userDefaults.synchronize()
        }
    }
    
    var optOut: Bool {
        get {
            return userDefaults.bool(forKey: MatomoUserDefaults.Key.optOut)
        }
        set {
            userDefaults.set(newValue, forKey: MatomoUserDefaults.Key.optOut)
            userDefaults.synchronize()
        }
    }
    
    var clientId: String? {
        get {
            return userDefaults.string(forKey: MatomoUserDefaults.Key.clientID)
        }
        set {
            userDefaults.setValue(newValue, forKey: MatomoUserDefaults.Key.clientID)
            userDefaults.synchronize()
        }
    }
    
    var visitorUserId: String? {
        get {
            return userDefaults.string(forKey: MatomoUserDefaults.Key.visitorUserID);
        }
        set {
            userDefaults.setValue(newValue, forKey: MatomoUserDefaults.Key.visitorUserID);
            userDefaults.synchronize()
        }
    }
}

extension MatomoUserDefaults {
    fileprivate struct Key {
        static let totalNumberOfVisits = "PiwikTotalNumberOfVistsKey"
        static let currentVisitTimestamp = "PiwikCurrentVisitTimestampKey"
        static let previousVistsTimestamp = "PiwikPreviousVistsTimestampKey"
        static let firstVistsTimestamp = "PiwikFirstVistsTimestampKey"
        
        // Note:    To be compatible with previous versions, the clientID key retains its old value,
        //          even though it is now a misnomer since adding visitorUserID makes it a bit confusing.
        static let clientID = "PiwikVisitorIDKey"
        static let visitorUserID = "PiwikVisitorUserIDKey"
        static let optOut = "PiwikOptOutKey"
    }
}
