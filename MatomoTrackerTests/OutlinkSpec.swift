@testable import MatomoTracker
import Foundation
import Testing

extension MatomoTrackerSpecs {
    @Suite("Outlink tracking")
    @MainActor
    struct OutlinkSpec {
        /// Tracks an outlink and returns the query items of the queued event, or nil if nothing was queued.
        private func trackedQueryItems(for url: URL, dimensions: [CustomDimension] = [], optedOut: Bool = false) -> [String: String]? {
            var queuedEvent: Event?
            let queue = QueueMock()
            queue.enqueueEventsHandler = { events, _ in
                queuedEvent = events.first
            }
            let tracker = MatomoTracker.fixture(queue: queue, dispatcher: DispatcherMock())
            tracker.isOptedOut = optedOut
            defer { tracker.isOptedOut = false }
            tracker.trackOutlink(url, dimensions: dimensions)
            return queuedEvent.map { EventAPISerializer().queryItems(for: $0) }
        }

        @Test("sends the url as link and url parameter", arguments: [
            "https://example.com/page?a=1",
            "http://example.com",
            "ftp://example.com/file.zip",
            "mailto:hello@example.com",
            "tel:+491234567",
            "myapp://settings",
        ])
        func sendsLinkAndURL(urlString: String) throws {
            let url = try #require(URL(string: urlString))
            let items = try #require(trackedQueryItems(for: url))
            #expect(items["link"]?.removingPercentEncoding == urlString)
            #expect(items["url"]?.removingPercentEncoding == urlString)
        }

        @Test("encodes the url only once")
        func encodesURLOnce() throws {
            let url = try #require(URL(string: "https://example.com/%C3%A9t%C3%A9?q=a%20b"))
            let items = try #require(trackedQueryItems(for: url))
            let link = try #require(items["link"])
            #expect(!link.contains("%25"))
            #expect(link.removingPercentEncoding == "https://example.com/été?q=a b")
            #expect(items["url"] == link)
        }

        @Test("isn't a custom action and has no page title")
        func isNoCustomAction() throws {
            let items = try #require(trackedQueryItems(for: URL(string: "https://example.com")!))
            #expect(items["ca"] == nil)
            #expect(items["action_name"] == "")
        }

        @Test("sends the dimensions")
        func sendsDimensions() throws {
            let items = try #require(trackedQueryItems(for: URL(string: "https://example.com")!, dimensions: [CustomDimension(index: 3, value: "in-app-browser")]))
            #expect(items["dimension3"] == "in-app-browser")
        }

        @Test("doesn't track a url without a scheme", arguments: ["/help", "help", "example.com/page"])
        func ignoresURLWithoutScheme(urlString: String) throws {
            let url = try #require(URL(string: urlString))
            #expect(trackedQueryItems(for: url) == nil)
        }

        @Test("doesn't track if the user opted out")
        func respectsOptOut() {
            #expect(trackedQueryItems(for: URL(string: "https://example.com")!, optedOut: true) == nil)
        }

        @Test("can decode events persisted before outlinks were supported")
        func decodesEventsWithoutLink() throws {
            let data = try JSONEncoder().encode(Event.fixture())
            let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect(object.keys.contains("link") == false)
            let decoded = try JSONDecoder().decode(Event.self, from: JSONSerialization.data(withJSONObject: object))
            #expect(decoded.link == nil)
        }
    }
}
