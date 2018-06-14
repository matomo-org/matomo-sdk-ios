import Foundation

#if os(OSX)
    import WebKit
#elseif os(iOS)
    import UIKit
#endif

final class URLSessionDispatcher: Dispatcher {
    
    let serializer = EventSerializer()
    let timeout: TimeInterval
    let session: URLSession
    let baseURL: URL

    private(set) var userAgent: String?
    
    /// Generate a URLSessionDispatcher instance
    ///
    /// - Parameters:
    ///   - baseURL: The url of the Matomo server. This url has to end in `piwik.php`.
    ///   - userAgent: An optional parameter for custom user agent.
    init(baseURL: URL, userAgent: String? = nil) {                
        self.baseURL = baseURL
        self.timeout = 5
        self.session = URLSession.shared
        DispatchQueue.main.async {
            self.userAgent = userAgent ?? URLSessionDispatcher.defaultUserAgent()
        }
    }
    
    private static func defaultUserAgent() -> String {
        assertMainThread()
        #if os(OSX)
            let webView = WebView(frame: .zero)
            let currentUserAgent = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? ""
        #elseif os(iOS)
            let webView = UIWebView(frame: .zero)
            var currentUserAgent = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? ""
            if let regex = try? NSRegularExpression(pattern: "\\((iPad|iPhone);", options: .caseInsensitive) {
                let deviceModel = Device.makeCurrentDevice().platform
                currentUserAgent = regex.stringByReplacingMatches(
                    in: currentUserAgent,
                    options: .withTransparentBounds,
                    range: NSRange(location: 0, length: currentUserAgent.count),
                    withTemplate: "(\(deviceModel);"
                )
            }
        #elseif os(tvOS)
            let currentUserAgent = ""
        #endif
        return currentUserAgent.appending(" MatomoTracker SDK URLSessionDispatcher")
    }
    
    func send(events: [Event], success: @escaping ()->(), failure: @escaping (_ error: Error)->()) {
        let jsonBody: Data
        do {
            jsonBody = try serializer.jsonData(for: events)
        } catch  {
            failure(error)
            return
        }
        let request = buildRequest(baseURL: baseURL, method: "POST", contentType: "application/json; charset=utf-8", body: jsonBody)
        send(request: request, success: success, failure: failure)
    }
    
    private func buildRequest(baseURL: URL, method: String, contentType: String? = nil, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: baseURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
        request.httpMethod = method
        body.map { request.httpBody = $0 }
        contentType.map { request.setValue($0, forHTTPHeaderField: "Content-Type") }
        userAgent.map { request.setValue($0, forHTTPHeaderField: "User-Agent") }
        return request
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

