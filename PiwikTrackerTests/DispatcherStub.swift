@testable import PiwikTracker

final class DispatcherStub: Dispatcher {
    public var baseURL: URL = URL(string: "http://piwik.org/spec_url")!

    struct Callback {
        typealias SendEvents = (_ events: [Event], _ success: () -> (), _ failure: () -> ()) -> ()
    }
    
    var sendEvents: Callback.SendEvents? = nil
    
    let userAgent: String? = "DispatcherStub"
    
    func send(events: [Event], success: () -> (), failure: () -> ()) {
        sendEvents?(events, success, failure)
    }
}
