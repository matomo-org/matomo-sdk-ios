import Foundation

public protocol Dispatcher {
    
    var baseURL: URL { get }
    
    var userAgent: String? { get }
    
    var cookie: String? { get set }
    
    func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ error: Error)->())
}
