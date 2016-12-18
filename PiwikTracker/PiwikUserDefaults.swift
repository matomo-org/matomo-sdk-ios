import Foundation

/// PiwikUserDefaults is a wrapper for the UserDefaults with properties
/// mapping onto values stored in the UserDefaults.
/// All getter and setter are sideeffect free and automatically syncronize
/// after writing.
internal class PiwikUserDefaults {
    internal static let standard = PiwikUserDefaults()
    internal let userDefaults = UserDefaults.standard
    
    internal var totalNumberOfVisits: UInt32 {
        get {
            return UInt32(self.userDefaults.integer(forKey: PiwikUserDefaults.Constants.UserDefaultTotalNumberOfVisitsKey))
        }
        set {
            self.userDefaults.set(newValue, forKey: PiwikUserDefaults.Constants.UserDefaultTotalNumberOfVisitsKey)
            self.userDefaults.synchronize()
        }
    }
    
    internal var firstVisit: Date? {
        get {
            return self.date(forKey: PiwikUserDefaults.Constants.UserDefaultFirstVistsTimestampKey)
        }
        set {
            self.userDefaults.set(newValue, forKey: PiwikUserDefaults.Constants.UserDefaultFirstVistsTimestampKey)
            self.userDefaults.synchronize()
        }
    }
    
    internal var previousVisit: Date? {
        get {
            return self.date(forKey: PiwikUserDefaults.Constants.UserDefaultPreviousVistsTimestampKey)
        }
        set {
            self.userDefaults.set(newValue, forKey: PiwikUserDefaults.Constants.UserDefaultPreviousVistsTimestampKey)
            self.userDefaults.synchronize()
        }
    }
    
    internal var currentVisit: Date? {
        get {
            return self.date(forKey: PiwikUserDefaults.Constants.UserDefaultCurrentVisitTimestampKey)
        }
        set {
            self.userDefaults.set(newValue, forKey: PiwikUserDefaults.Constants.UserDefaultCurrentVisitTimestampKey)
            self.userDefaults.synchronize()
        }
    }
    
    internal var optOut: Bool {
        get {
            return self.userDefaults.bool(forKey: PiwikUserDefaults.Constants.UserDefaultOptOutKey)
        }
        set {
            self.userDefaults.set(newValue, forKey: PiwikUserDefaults.Constants.UserDefaultOptOutKey)
            self.userDefaults.synchronize()
        }
    }
    
    internal func clientId(prefix: String) -> String? {
        let key = "\(prefix)_\(PiwikUserDefaults.Constants.UserDefaultVisitorIDKey)"
        return self.userDefaults.string(forKey: key)
    }
    
    internal func set(clientId: String, prefix: String) {
        let key = "\(prefix)_\(PiwikUserDefaults.Constants.UserDefaultVisitorIDKey)"
        self.userDefaults.setValue(clientId, forKey: key)
        self.userDefaults.synchronize()
    }
}

extension PiwikUserDefaults {
    internal func set(date: Date, forKey key: String) {
        let timestamp = date.timeIntervalSince1970
        self.userDefaults.set(timestamp, forKey: key)
    }
    internal func date(forKey key: String) -> Date? {
        guard self.userDefaults.object(forKey: key) != nil else { return nil }
        let storedDouble = self.userDefaults.double(forKey: key)
        return Date(timeIntervalSince1970: storedDouble)
    }
}

extension PiwikUserDefaults {
    fileprivate struct Constants {
        static let UserDefaultTotalNumberOfVisitsKey = "PiwikTotalNumberOfVistsKey"
        static let UserDefaultCurrentVisitTimestampKey = "PiwikCurrentVisitTimestampKey"
        static let UserDefaultPreviousVistsTimestampKey = "PiwikPreviousVistsTimestampKey"
        static let UserDefaultFirstVistsTimestampKey = "PiwikFirstVistsTimestampKey"
        static let UserDefaultVisitorIDKey = "PiwikVisitorIDKey"
        static let UserDefaultOptOutKey = "PiwikOptOutKey"
    }
}
