import Foundation

public final class URLSessionDispatcher: Dispatcher {
    
    private let serializer = EventAPISerializer()
    private let timeout: TimeInterval
    private let session: URLSession
    public let baseURL: URL

    private var userAgent: String?
    
    /// Generate a URLSessionDispatcher instance
    ///
    /// - Parameters:
    ///   - baseURL: The url of the Matomo server. This url has to end in `piwik.php`.
    ///   - userAgent: An optional parameter for custom user agent.
    ///   - timeout: The timeout interval for the request. The default is 5.0.
    public init(baseURL: URL, userAgent: String? = nil, timeout: TimeInterval = 5.0) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.session = URLSession.shared
        self.userAgent = userAgent ?? UserAgent(application: Application.makeCurrentApplication(), device: Device.makeCurrentDevice()).stringValue
    }
    
    public func send(events: [Event], completion: @escaping (Result<Void, Error>) -> Void) {
        let jsonBody: Data
        do {
            jsonBody = try serializer.jsonData(for: events)
        } catch  {
            completion(.failure(error))
            return
        }
        let request = buildRequest(baseURL: baseURL, method: "POST", contentType: "application/json; charset=utf-8", body: jsonBody)
        send(request: request, completion: completion)
    }
    
    private func buildRequest(baseURL: URL, method: String, contentType: String? = nil, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: baseURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
        request.httpMethod = method
        body.map { request.httpBody = $0 }
        contentType.map { request.setValue($0, forHTTPHeaderField: "Content-Type") }
        userAgent.map { request.setValue($0, forHTTPHeaderField: "User-Agent") }
        return request
    }
    
    private func send(request: URLRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            // should we check the response?
            // let dataString = String(data: data!, encoding: String.Encoding.utf8)
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        task.resume()
    }
    
}

