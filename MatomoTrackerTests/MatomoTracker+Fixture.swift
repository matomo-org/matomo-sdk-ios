@testable import MatomoTracker

extension MatomoTracker {
    static func fixture(siteId: String = "fixture_site_id", baseURL: URL = URL(string: "http://demo2.matomo.org/fixture")!, userAgent: String? = nil) -> MatomoTracker {
        MatomoTracker(siteId: siteId, baseURL: baseURL, userAgent: userAgent)
    }
    static func fixture(siteId: String = "fixture_site_id", queue: Queue, dispatcher: Dispatcher) -> MatomoTracker {
        MatomoTracker(siteId: siteId, queue: queue, dispatcher: dispatcher)
    }
}
