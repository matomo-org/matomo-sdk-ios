import Foundation

public protocol Dispatcher {
    
    var baseURL: URL { get }
    
    func send(events: [Event], completion: @escaping (Result<Void, Error>) -> Void)
}

extension Dispatcher {

    @available(*, deprecated, message: "send(events:, completio:) instead")
    func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        send(events: events) { result in
            switch result {
            case .success(_): success()
            case .failure(let error): failure(error)
            }
        }
    }
}
