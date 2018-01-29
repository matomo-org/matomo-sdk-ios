//
//  EventSerializer.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 11.01.18.
//  Copyright © 2018 PIWIK. All rights reserved.
//

import Foundation

final class EventSerializer {
    internal func jsonData(for events: [Event]) throws -> Data {
        let eventsAsQueryItems = events.map({ $0.queryItems })
        let serializedEvents = eventsAsQueryItems.map({ items in
            items.flatMap({ item in
                guard let value = item.value,
                    let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryParameterAllowed) else { return nil }
                return "\(item.name)=\(encodedValue)"
            }).joined(separator: "&")
        })
        let body = ["requests": serializedEvents.map({ "?\($0)" })]
        return try JSONSerialization.data(withJSONObject: body, options: [])
    }
}

fileprivate extension Event {
    
    private func customVariableParameterValue() -> String {
        let customVariableParameterValue: [String] = customVariables.map { "\"\($0.index)\":[\"\($0.name)\",\"\($0.value)\"]" }
        return "{\(customVariableParameterValue.joined(separator: ","))}"
    }

    var queryItems: [URLQueryItem] {
        get {
            let items = [
                URLQueryItem(name: "idsite", value: siteId),
                URLQueryItem(name: "rec", value: "1"),
                // Visitor
                URLQueryItem(name: "_id", value: visitor.id),
                URLQueryItem(name: "uid", value: visitor.userId),
                
                // Session
                URLQueryItem(name: "_idvc", value: "\(session.sessionsCount)"),
                URLQueryItem(name: "_viewts", value: "\(Int(session.lastVisit.timeIntervalSince1970))"),
                URLQueryItem(name: "_idts", value: "\(Int(session.firstVisit.timeIntervalSince1970))"),
                
                URLQueryItem(name: "url", value:url?.absoluteString),
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
                
                ].filter { $0.value != nil }

            let dimensionItems = dimensions.map { URLQueryItem(name: "dimension\($0.index)", value: $0.value) }
            let customItems = customTrackingParameters.map { return URLQueryItem(name: $0.key, value: $0.value) }
            let customVariableItems = customVariables.count > 0 ? [URLQueryItem(name: "_cvar", value: customVariableParameterValue())] : []

            return items + dimensionItems + customItems + customVariableItems
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

fileprivate extension CharacterSet {
    
    /// Returns the character set for characters allowed in a query parameter URL component.
    fileprivate static var urlQueryParameterAllowed: CharacterSet {
        return CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&/?"))
    }
}
