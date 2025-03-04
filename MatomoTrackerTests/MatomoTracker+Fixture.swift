@testable import MatomoTracker

extension MatomoTracker {
    static func fixture(siteID: String = "fixture_site_id", baseURL: URL = URL(string: "http://demo2.matomo.org/fixture")!, userAgent: String? = nil) -> MatomoTracker {
        MatomoTracker(siteID: siteID, baseURL: baseURL, userAgent: userAgent)
    }
    static func fixture(siteID: String = "fixture_site_id", queue: Queue, dispatcher: Dispatcher) -> MatomoTracker {
        MatomoTracker(siteID: siteID, queue: queue, dispatcher: dispatcher)
    }
}
