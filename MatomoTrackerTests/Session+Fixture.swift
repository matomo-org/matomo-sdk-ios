@testable import MatomoTracker

extension Session {
    static func fixture(sessionsCount: Int = 0, lastVisit: Date = Date(), firstVisit: Date = Date()) -> Session {
        Session(sessionsCount: sessionsCount, lastVisit: lastVisit, firstVisit: firstVisit)
    }
}
