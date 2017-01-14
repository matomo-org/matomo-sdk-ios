import Foundation

public protocol Dispatcher {
    var userAgent: String? { get }
    
    func send(event: Event, success: ()->(), failure: (_ shouldContinue: Bool)->());
    
    func send(events: [Event], success: ()->(), failure: (_ shouldContinue: Bool)->());
}
