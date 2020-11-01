import Foundation

public protocol Dispatcher {
    
    var baseURL: URL { get }
    
    var userAgent: String? { get }
    
    func send(events: [Event], completion: @escaping (Result<Void, Error>) -> Void)
}

extension Dispatcher {
    //func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ error: Error)->())
}
