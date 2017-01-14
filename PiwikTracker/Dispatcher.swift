import Foundation

public protocol Dispatcher {
    var userAgent: String? { get }
        
    func send(events: [Event], success: ()->(), failure: ()->());
}
