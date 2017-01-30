import Foundation

final class URLSessionDispatcher: Dispatcher {
    
    let timeout: TimeInterval
    let session: URLSession
    let baseURL: URL
    
    var userAgent: String? = "Piwik iOS SDK URLSessionDispatcher"
    
    init(baseURL: URL) {
        if !baseURL.absoluteString.hasSuffix("piwik.php") {
            fatalError("The baseURL is expected to end in piwik.php")
        }
        self.baseURL = baseURL
        self.timeout = 5
        self.session = URLSession.shared
    }
    
    func send(event: Event, success: @escaping ()->(), failure: @escaping (_ shouldContinue: Bool)->()) {
        let url = baseURL.setting(event.queryItems)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        send(request: request, success: success, failure: failure)
    }
    
    func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ shouldContinue: Bool)->()) {
        let eventsAsQueryItems = events.map({ event in event.queryItems })
        let serializedEvents = eventsAsQueryItems.map({ items in
            items.map({ item in
                return "\(item.name)=\(item.value)"
            }).joined(separator: "&")
        })
        let body = ["requests": serializedEvents.map({ "?\($0)" })]
        guard let jsonBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            puts("Unable to serialize JSONData")
            failure(false)
            return
        }
        var request = URLRequest(url: baseURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        send(request: request, success: success, failure: failure)
    }
    
    private func send(request: URLRequest, success: @escaping ()->(), failure: @escaping (_ shouldContinue: Bool)->()) {
        let task = session.dataTask(with: request) { data, response, error in
            if error == nil {
                success()
            } else {
                failure(false)
            }
        }
        task.resume()
    }
    
}

fileprivate extension Event {
    var queryItems: [URLQueryItem] {
        get {
            return [
                // Visitor
                URLQueryItem(name: "_id", value: visitor.id),
                URLQueryItem(name: "uid", value: visitor.userId),
                
                // Session
                URLQueryItem(name: "_idvc", value: "\(session.sessionsCount)"),
                URLQueryItem(name: "_viewts", value: "\(session.lastVisit.timeIntervalSince1970)"),
                URLQueryItem(name: "_idts", value: "\(session.firstVisit.timeIntervalSince1970)"),
                
                URLQueryItem(name: "url", value:url.absoluteString),
                URLQueryItem(name: "action_name", value: actionName.joined(separator: "/")),
                URLQueryItem(name: "lang", value: language),
                URLQueryItem(name: "urlref", value: referer?.absoluteString),
                URLQueryItem(name: "new_visit", value: isNewSession ? "1" : nil),
                
                URLQueryItem(name: "h", value: DateFormatter.hourDateFormatter.string(from: date)),
                URLQueryItem(name: "m", value: DateFormatter.minuteDateFormatter.string(from: date)),
                URLQueryItem(name: "s", value: DateFormatter.secondsDateFormatter.string(from: date)),
                
                ].filter({ $0.value != nil }) // remove the items that lack the value
        }
    }
}

fileprivate extension DateFormatter {
    static let hourDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter
    }()
    static let minuteDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        return dateFormatter
    }()
    static let secondsDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ss"
        return dateFormatter
    }()
}

fileprivate extension URL {
    func setting(_ items: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = items
        return components.url ?? self
    }
}
