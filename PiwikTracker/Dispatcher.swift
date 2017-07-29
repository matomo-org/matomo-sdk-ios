import Foundation

public protocol Dispatcher {
    
    var baseURL: URL { get }
    
    var userAgent: String? { get }
        
    func send(event: Event, success: @escaping ()->(), failure: @escaping (_ error: Error)->())
    
    func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ error: Error)->())
}
