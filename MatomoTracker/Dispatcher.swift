import Foundation

/// Sends events to the Matomo server.
///
/// The `MatomoTracker` calls `send(events:success:failure:)` on an internal serial queue, not on the main thread.
/// The `success` and `failure` callbacks can be called on any thread.
public protocol Dispatcher {
    
    var baseURL: URL { get }
    
    var userAgent: String? { get }
    
    func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ error: Error)->())
}
