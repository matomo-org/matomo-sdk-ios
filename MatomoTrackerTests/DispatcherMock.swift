import Foundation
@testable import MatomoTracker

/// The tracker calls its dispatcher on an internal queue, so the call counts can be read from any thread.
final class DispatcherMock: Dispatcher, @unchecked Sendable {

    private let counts = Locked((baseURLOnSet: 0, userAgentOnSet: 0, sendEvents: 0))

    var baseURLOnSetCallCount: Int { counts.value.baseURLOnSet }
    var baseURL: URL = URL(string: "http://matomo.org/spec_url")!{
        didSet {
            counts.mutate { $0.baseURLOnSet += 1 }
        }
    }
    
    var userAgentOnSetCallCount: Int { counts.value.userAgentOnSet }
    var userAgent: String? {
        didSet {
            counts.mutate { $0.userAgentOnSet += 1 }
        }
    }

    var sendEventsCallCount: Int { counts.value.sendEvents }
    var sendEventsHandler: (([Event], @escaping () -> Void,@escaping (Error) -> Void) -> Void)? = nil
    func send(events: [Event], success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        counts.mutate { $0.sendEvents += 1 }
        sendEventsHandler?(events, success, failure)
    }
}
