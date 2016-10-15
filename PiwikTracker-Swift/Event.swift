//
//  Event.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 11.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation
import UIKit

public struct Event {
    
    static var _UTCDateFormatter: DateFormatter?
    static var UTCDateFormatter: DateFormatter {
        get {
            if let dateFormatter = _UTCDateFormatter {
                return dateFormatter
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            _UTCDateFormatter = dateFormatter
            return dateFormatter
        }
    }
    
    internal(set) public var parametersDictionary: [String:String] = [:]
    
    
    init() {
        parametersDictionary[PiwikConstants.ParameterScreenReseloution] = String(format: "%.0fx%.0f", UIDevice.screenSize.width, UIDevice.screenSize.height)
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: now)
        parametersDictionary[PiwikConstants.ParameterHours] = "\(components.hour)"
        parametersDictionary[PiwikConstants.ParameterMinutes] = "\(components.minute)"
        parametersDictionary[PiwikConstants.ParameterSeconds] = "\(components.second)"
        parametersDictionary[PiwikConstants.ParameterDateAndTime] = Event.UTCDateFormatter.string(from: now)
    }
    
    mutating func setParameters(fromUserDefaults userDefaults: PiwikUserDefaults) {
        // parametersDictionary[PiwikConstants.ParameterVisitorID] = userDefaults.clientId(withKeyPrefix: siteId)
        parametersDictionary[PiwikConstants.ParameterFirstVisitTimestamp] = "\(userDefaults.firstVisit.timeIntervalSince1970)"
        parametersDictionary[PiwikConstants.ParameterTotalNumberOfVisits] = "\(userDefaults.totalNumberOfVisits)"
        if let previousVisit = userDefaults.previousVisit {
            parametersDictionary[PiwikConstants.ParameterPreviousVisitTimestamp] = "\(previousVisit.timeIntervalSince1970)"
        }
    }
    
    mutating func setParameters(fromTracker tracker: PiwikTracker) {
        parametersDictionary[PiwikConstants.ParameterSiteID] = tracker.siteID
        parametersDictionary[PiwikConstants.ParameterURL] = "http://piwik.org"
        if let userID = tracker.userID {
            parametersDictionary[PiwikConstants.ParameterUserID] = userID
        }
    }
}

extension Event {
    init(withViews views: [String], addPrefix: Bool) {
        self.init()
        var actionName: String
        if addPrefix {
            let prefixedViews = [PiwikConstants.PrefixView] + views
            actionName = prefixedViews.joined(separator: "/")
        } else {
            actionName = views.joined(separator: "/")
        }
        parametersDictionary[PiwikConstants.ParameterActionName] = actionName
        // FIXME: add proper URL
        parametersDictionary[PiwikConstants.ParameterURL] = ""
    }
    
    init(withOutlink outlink: String) {
        self.init()
        parametersDictionary[PiwikConstants.ParameterLink] = outlink
        parametersDictionary[PiwikConstants.ParameterURL] = outlink
    }
    
    init(withDownload download: String) {
        self.init()
        parametersDictionary[PiwikConstants.ParameterDownload] = download
        parametersDictionary[PiwikConstants.ParameterURL] = download
    }
    
    init(withCategory category: String, action: String, name: String? = nil, value: String? = nil) {
        self.init()
        parametersDictionary[PiwikConstants.ParameterEventCategory] = category
        parametersDictionary[PiwikConstants.ParameterEventAction] = action
        parametersDictionary[PiwikConstants.ParameterEventName] = name
        parametersDictionary[PiwikConstants.ParameterEventValue] = value
        // FIXME: add proper URL
        parametersDictionary[PiwikConstants.ParameterURL] = ""
    }
}



