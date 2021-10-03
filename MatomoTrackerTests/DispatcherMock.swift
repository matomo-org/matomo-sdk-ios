@testable import MatomoTracker

final class DispatcherMock: Dispatcher {

    private(set) var baseURLOnSetCallCount = 0
    var baseURL: URL = URL(string: "http://matomo.org/spec_url")!{
        didSet {
            baseURLOnSetCallCount += 1
        }
    }
    
    private(set) var userAgentOnSetCallCount = 0
    var userAgent: String? {
        didSet {
            userAgentOnSetCallCount += 1
        }
    }

    private(set) var sendEventsCallCount = 0
    var sendEventsHandler: (([Event], @escaping () -> Void,@escaping (Error) -> Void) -> Void)? = nil
    func send(events: [Event], success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        sendEventsCallCount += 1
        sendEventsHandler?(events, success, failure)
    }
}

