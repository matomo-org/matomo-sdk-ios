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

            /// The same cases as in the Matomo Android SDK's `TrackerTest`
            /// (`testLastScreenUrl`, `testSetURL`, `testApplicationDomain`, `testUrlPathCorrection`).
            @Test("behaves like the Android SDK", arguments: [
                ("http://this.is.our.package/", "thang", "http://this.is.our.package/thang"),
                ("http://test.com/", "me", "http://test.com/me"),
                ("http://test.com/", "https://my.com/secure", "https://my.com/secure"),
                ("http://my-domain.com", "test/test", "http://my-domain.com/test/test"),
                ("https://package/", "/", "https://package/"),
            ])
            func behavesLikeAndroid(contentBase: String, relativeURL: String, expected: String) {
                #expect(url(for: URL(string: relativeURL), contentBase: contentBase) == expected)
            }

            @Test("treats urls without `://` as relative, like the Android SDK", arguments: [
                ("id:123/details", "http://org.example.app/id:123/details"),
                ("myapp:settings", "http://org.example.app/myapp:settings"),
            ])
            func treatsURLsWithoutSlashesAsRelative(relativeURL: String, expected: String) {
                #expect(url(for: URL(string: relativeURL), contentBase: "http://org.example.app") == expected)
            }

            @Test("keeps an absolute url unchanged", arguments: [
                "https://example.org/mainPage",
                "myapp://settings",
            ])
            func keepsAbsoluteURL(absoluteURL: String) {
                #expect(url(for: URL(string: absoluteURL), contentBase: "http://org.example.app") == absoluteURL)
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
