@testable import MatomoTracker
import Foundation
import Testing

extension MatomoTrackerSpecs {
    @Suite("Event")
    @MainActor
    struct EventSpec {
        @Suite("url")
        @MainActor
        struct EventURL {
            private func url(for url: URL?, contentBase: String?, action: [String] = ["mainPage", "id.123"]) -> String? {
                let tracker = MatomoTracker.fixture(queue: MemoryQueue(), dispatcher: DispatcherMock())
                tracker.contentBase = contentBase.flatMap { URL(string: $0) }
                let event = Event(tracker: tracker, action: action, url: url, isCustomAction: false)
                return event.url?.absoluteString
            }

            @Test("prefixes a relative url with the contentBase", arguments: [
                ("http://org.example.app", "/mainPage/id.123", "http://org.example.app/mainPage/id.123"),
                ("http://org.example.app", "mainPage/id.123", "http://org.example.app/mainPage/id.123"),
                ("http://org.example.app/", "/mainPage/id.123", "http://org.example.app/mainPage/id.123"),
                ("http://org.example.app/", "mainPage/id.123", "http://org.example.app/mainPage/id.123"),
                ("https://example.com/app", "/mainPage/id.123", "https://example.com/app/mainPage/id.123"),
                ("http://org.example.app", "/search?q=a%20b#top", "http://org.example.app/search?q=a%20b#top"),
            ])
            func prefixesRelativeURL(contentBase: String, relativeURL: String, expected: String) {
                #expect(url(for: URL(string: relativeURL), contentBase: contentBase) == expected)
            }

            @Test("keeps an absolute url unchanged")
            func keepsAbsoluteURL() {
                #expect(url(for: URL(string: "https://example.org/mainPage"), contentBase: "http://org.example.app") == "https://example.org/mainPage")
            }

            @Test("keeps a relative url unchanged without a contentBase")
            func keepsRelativeURLWithoutContentBase() {
                #expect(url(for: URL(string: "/mainPage/id.123"), contentBase: nil) == "/mainPage/id.123")
            }

            @Test("builds the url from the contentBase and actions if no url is given")
            func buildsURLFromActions() {
                #expect(url(for: nil, contentBase: "http://org.example.app") == "http://org.example.app/mainPage/id.123")
            }
        }
    }
}
