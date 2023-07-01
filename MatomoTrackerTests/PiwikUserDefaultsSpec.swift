@testable import MatomoTracker
import Quick
import Nimble

class MatomoUserDefaultsSpec: QuickSpec {
    override class func spec() {
        describe("suiteMigration") {
            it("should migrate data for the default suite") {
                self.setMigrateableData(totalNumberOfVisists: 10, firstVisit: Date(timeIntervalSince1970: 100), previousVisit: Date(timeIntervalSince1970: 101), currentVisit: Date(timeIntervalSince1970: 102), optOut: true, clientId: "_specVisitorID")
                self.removeAllInSuite(suite: "_specSuite")
                var userDefaults = MatomoUserDefaults(suiteName: "_specSuite")
                userDefaults.copy(from: UserDefaults.standard)
                expect(userDefaults.totalNumberOfVisits) == 10
                expect(userDefaults.firstVisit) == Date(timeIntervalSince1970: 100)
                expect(userDefaults.previousVisit) == Date(timeIntervalSince1970: 101)
                expect(userDefaults.currentVisit) == Date(timeIntervalSince1970: 102)
                expect(userDefaults.optOut) == true
                expect(userDefaults.clientId) == "_specVisitorID"
            }
        }
    }
    
    /// Tries to remove all data stored in a given suite
    private class func removeAllInSuite(suite: String) {
        guard let newuserDefaults = UserDefaults(suiteName: suite) else { return }
        let allKeys: [String]? = Array(newuserDefaults.dictionaryRepresentation().keys)
        for key in allKeys ?? [] {
            newuserDefaults.removeObject(forKey: key)
        }
    }
    
    private class func setMigrateableData(totalNumberOfVisists: Int, firstVisit: Date?, previousVisit: Date?, currentVisit: Date?, optOut: Bool, clientId: String?) {
        UserDefaults.standard.set(totalNumberOfVisists, forKey: MatomoUserDefaults.Key.totalNumberOfVisits)
        UserDefaults.standard.set(firstVisit, forKey: MatomoUserDefaults.Key.firstVistsTimestamp)
        UserDefaults.standard.set(previousVisit, forKey: MatomoUserDefaults.Key.previousVistsTimestamp)
        UserDefaults.standard.set(currentVisit, forKey: MatomoUserDefaults.Key.currentVisitTimestamp)
        UserDefaults.standard.set(optOut, forKey: MatomoUserDefaults.Key.optOut)
        UserDefaults.standard.set(clientId, forKey: MatomoUserDefaults.Key.clientID)
    }
}
