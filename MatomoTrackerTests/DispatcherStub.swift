@testable import MatomoTracker

final class DispatcherStub: Dispatcher {

    public var baseURL: URL = URL(string: "http://matomo.org/spec_url")!

    struct Callback {
        typealias SendEvents = (_ events: [Event], _ completion: @escaping (Result<Void, Error>) -> Void) -> ()
    }
    
    var sendEvents: Callback.SendEvents? = nil
    
    let userAgent: String? = "DispatcherStub"
    
    func send(events: [Event], completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.sendEvents?(events, completion)
        }
    }
}
