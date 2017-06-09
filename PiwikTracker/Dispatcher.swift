import Foundation

public protocol Dispatcher {
    
    var baseURL: URL { get }
    
    var userAgent: String? { get set }
    
    func setUserAgent(ua: String)
    
    func send(event: Event, success: @escaping ()->(), failure: @escaping (_ shouldContinue: Bool)->())
    
    func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ shouldContinue: Bool)->())
}
