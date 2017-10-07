import Foundation

#if os(OSX)
    import WebKit
#elseif os(iOS)
    import UIKit
#endif

final class URLSessionDispatcher: Dispatcher {
    
    let timeout: TimeInterval
    let session: URLSession
    let baseURL: URL

    var userAgent: String? = {
        #if os(OSX)
            let webView = WebView(frame: .zero)
            let currentUserAgent = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? ""
        #elseif os(iOS)
            let webView = UIWebView(frame: .zero)
            let currentUserAgent = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? ""
        #elseif os(tvOS)
            let currentUserAgent = ""
        #endif
        return currentUserAgent.appending(" PiwikTracker SDK URLSessionDispatcher")
    }()
    
    /// Generate a URLSessionDispatcher instance
    ///
    /// - Parameters:
    ///   - baseURL: The url of the piwik server. This url has to end in `piwik.php`.
    ///   - userAgent: An optional parameter for custom user agent.
    init(baseURL: URL, userAgent: String? = nil) {
        if !baseURL.absoluteString.hasSuffix("piwik.php") {
            fatalError("The baseURL is expected to end in piwik.php")
        }
        self.baseURL = baseURL
        self.timeout = 5
        self.session = URLSession.shared
        if (userAgent != nil) {
            self.userAgent = userAgent
        }
    }
    
    func send(event: Event, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let url = baseURL.setting(event.queryItems)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        send(request: request, success: success, failure: failure)
    }
    
    func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let eventsAsQueryItems = events.map({ event in event.queryItems })
        let serializedEvents = eventsAsQueryItems.map({ items in
            items.flatMap({ item in
                guard let value = item.value,
                    let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
                return "\(item.name)=\(encodedValue)"
            }).joined(separator: "&")
        })
        let body = ["requests": serializedEvents.map({ "?\($0)" })]
        let jsonBody: Data
        do {
            jsonBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch  {
            failure(error)
            return
        }
        var request = URLRequest(url: baseURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        send(request: request, success: success, failure: failure)
    }
    
    private func send(request: URLRequest, success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let task = session.dataTask(with: request) { data, response, error in
            // should we check the response?
            // let dataString = String(data: data!, encoding: String.Encoding.utf8)
            if let error = error {
                failure(error)
            } else {
                success()
            }
        }
        task.resume()
    }
    
}

fileprivate extension Event {
    var queryItems: [URLQueryItem] {
        get {
            var items = [
                URLQueryItem(name: "idsite", value: siteId),
                URLQueryItem(name: "rec", value: "1"),
                // Visitor
                URLQueryItem(name: "_id", value: visitor.id),
                URLQueryItem(name: "uid", value: visitor.userId),
                
                // Session
                URLQueryItem(name: "_idvc", value: "\(session.sessionsCount)"),
                URLQueryItem(name: "_viewts", value: "\(Int(session.lastVisit.timeIntervalSince1970))"),
                URLQueryItem(name: "_idts", value: "\(Int(session.firstVisit.timeIntervalSince1970))"),
                
                URLQueryItem(name: "url", value:url.absoluteString),
                URLQueryItem(name: "action_name", value: actionName.joined(separator: "/")),
                URLQueryItem(name: "lang", value: language),
                URLQueryItem(name: "urlref", value: referer?.absoluteString),
                URLQueryItem(name: "new_visit", value: isNewSession ? "1" : nil),
                
                URLQueryItem(name: "h", value: DateFormatter.hourDateFormatter.string(from: date)),
                URLQueryItem(name: "m", value: DateFormatter.minuteDateFormatter.string(from: date)),
                URLQueryItem(name: "s", value: DateFormatter.secondsDateFormatter.string(from: date)),
                
                
                //screen resolution
                URLQueryItem(name: "res", value:String(format: "%1.0fx%1.0f", screenResolution.width, screenResolution.height)),

                URLQueryItem(name: "e_c", value: eventCategory),
                URLQueryItem(name: "e_a", value: eventAction),
                URLQueryItem(name: "e_n", value: eventName),
                URLQueryItem(name: "e_v", value: eventValue != nil ? "\(eventValue!)" : nil),
                
                ].filter({ $0.value != nil }) // remove the items that lack the value
            for dimension in dimensions {
                items.append(URLQueryItem(name: "dimension\(dimension.index)", value: dimension.value))
            }
            return items + customTrackingParameters.map({ key, value in return URLQueryItem(name: key, value: value) })
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
