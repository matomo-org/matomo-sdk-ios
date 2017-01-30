@testable import PiwikTracker

final class DispatcherStub: Dispatcher {
    public var baseURL: URL = URL(string: "http://piwik.org/spec_url")!

    struct Callback {
        typealias SendEvents = (_ events: [Event], _ success: () -> (), _ failure: (_ shouldContinue: Bool) -> ()) -> ()
    }
    
    var sendEvents: Callback.SendEvents? = nil
    
    let userAgent: String? = "DispatcherStub"
    
    
    func send(event: Event, success: @escaping ()->(), failure: @escaping (_ shouldContinue: Bool)->()){
        send(events: [event], success: success, failure: failure)
    }
    
    func send(events: [Event], success: @escaping () -> (), failure: @escaping (_ shouldContinue: Bool) -> ()) {
        sendEvents?(events, success, failure)
    }
}
