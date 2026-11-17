@testable import MatomoTracker
import Foundation
import Testing

extension MatomoTrackerSpecs {
    @Suite("MatomoUserDefaults")
    struct MatomoUserDefaultsSpec {
        @Suite("suiteMigration")
        struct SuiteMigration {
            @Test("should migrate data for the default suite")
            func migratesDataForTheDefaultSuite() {
                setMigrateableData(totalNumberOfVisits: 10, firstVisit: Date(timeIntervalSince1970: 100), previousVisit: Date(timeIntervalSince1970: 101), currentVisit: Date(timeIntervalSince1970: 102), optOut: true, clientId: "_specVisitorID")
                defer { removeMigrateableData() }
                removeAllInSuite(suite: "_specSuite")

                var userDefaults = MatomoUserDefaults(suiteName: "_specSuite")
                userDefaults.copy(from: UserDefaults.standard)

                #expect(userDefaults.totalNumberOfVisits == 10)
                #expect(userDefaults.firstVisit == Date(timeIntervalSince1970: 100))
                #expect(userDefaults.previousVisit == Date(timeIntervalSince1970: 101))
                #expect(userDefaults.currentVisit == Date(timeIntervalSince1970: 102))
                #expect(userDefaults.optOut == true)
                #expect(userDefaults.clientId == "_specVisitorID")
            }
        }
    }
}

private let migrateableKeys: [MatomoUserDefaults.Key] = [
    .totalNumberOfVisits, .firstVistsTimestamp, .previousVistsTimestamp,
    .currentVisitTimestamp, .optOut, .clientID,
]

private func setMigrateableData(totalNumberOfVisits: Int, firstVisit: Date?, previousVisit: Date?, currentVisit: Date?, optOut: Bool, clientId: String?) {
    UserDefaults.standard.set(totalNumberOfVisits, forKey: MatomoUserDefaults.Key.totalNumberOfVisits.rawValue)
    UserDefaults.standard.set(firstVisit, forKey: MatomoUserDefaults.Key.firstVistsTimestamp.rawValue)
    UserDefaults.standard.set(previousVisit, forKey: MatomoUserDefaults.Key.previousVistsTimestamp.rawValue)
    UserDefaults.standard.set(currentVisit, forKey: MatomoUserDefaults.Key.currentVisitTimestamp.rawValue)
    UserDefaults.standard.set(optOut, forKey: MatomoUserDefaults.Key.optOut.rawValue)
    UserDefaults.standard.set(clientId, forKey: MatomoUserDefaults.Key.clientID.rawValue)
}

/// Removes the migration data again, so it can't leak into other tests.
private func removeMigrateableData() {
    for key in migrateableKeys {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
