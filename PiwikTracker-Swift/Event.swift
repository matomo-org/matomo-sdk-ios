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
    
    internal let uuid = NSUUID().uuidString
    
    fileprivate(set) var parametersDictionary: [String:String] = [:]
    public var dictionary: [String:String] {
        get {
            var dictionary = parametersDictionary
            do {
                let visitCustomVariablesData = try JSONSerialization.data(withJSONObject: visitCustomVariables, options: [])
                dictionary[PiwikConstants.ParameterVisitScopeCustomVariables] = String(data: visitCustomVariablesData, encoding: .utf8)
            } catch {}
            return dictionary
        }
    }
    fileprivate var visitCustomVariables: [String:[String]] = [:]
    
    init() {
        parametersDictionary[PiwikConstants.ParameterScreenReseloution] = String(format: "%.0fx%.0f", Device.screenSize.width, Device.screenSize.height)
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: now)
        if let hour = components.hour, let minute = components.minute, let second = components.second {
            parametersDictionary[PiwikConstants.ParameterHours] = "\(hour)"
            parametersDictionary[PiwikConstants.ParameterMinutes] = "\(minute)"
            parametersDictionary[PiwikConstants.ParameterSeconds] = "\(second)"
        }
        parametersDictionary[PiwikConstants.ParameterDateAndTime] = Event.UTCDateFormatter.string(from: now)
        
        // this is quite what the android app does; Is there any need to add a path after this?
        parametersDictionary[PiwikConstants.ParameterURL] = "http://\(UIApplication.appName)"
    }
    
    mutating func setParameters(fromUserDefaults userDefaults: PiwikUserDefaults, andTracker tracker: PiwikTracker) {
        parametersDictionary[PiwikConstants.ParameterVisitorID] = userDefaults.clientId(withKeyPrefix: tracker.siteID)
        parametersDictionary[PiwikConstants.ParameterFirstVisitTimestamp] = "\(userDefaults.firstVisit.timeIntervalSince1970)"
        parametersDictionary[PiwikConstants.ParameterTotalNumberOfVisits] = "\(userDefaults.totalNumberOfVisits)"
        if let previousVisit = userDefaults.previousVisit {
            parametersDictionary[PiwikConstants.ParameterPreviousVisitTimestamp] = "\(previousVisit.timeIntervalSince1970)"
        }
        parametersDictionary[PiwikConstants.ParameterSiteID] = tracker.siteID
        parametersDictionary[PiwikConstants.ParameterURL] = "http://piwik.org"
        if let userID = tracker.userID {
            parametersDictionary[PiwikConstants.ParameterUserID] = userID
        }
        if tracker.includeDefaultCustomVariable {
            visitCustomVariables["1"] = ["Platform", Device.platformName]
            visitCustomVariables["2"] = ["OS version", Device.osVersion]
            visitCustomVariables["3"] = ["App version", Device.appVersion]
        }
        if tracker.sessionStart {
            parametersDictionary[PiwikConstants.ParameterSessionStart] = "1"
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
    
    init(withCategory category: String, action: String, name: String? = nil, value: Float? = nil) {
        self.init()
        parametersDictionary[PiwikConstants.ParameterEventCategory] = category
        parametersDictionary[PiwikConstants.ParameterEventAction] = action
        parametersDictionary[PiwikConstants.ParameterEventName] = name
        parametersDictionary[PiwikConstants.ParameterEventValue] = "\(value)"
    }
    
    init(withException description: String, fatal: Bool, addPrefix: Bool) {
        self.init()
        let limitedDescription = UInt(description.lengthOfBytes(using: .utf8)) > PiwikConstants.ExceptionDescriptionMaximumLength ? description.prefix(ofMaximumLength: PiwikConstants.ExceptionDescriptionMaximumLength) : description
        let components: [String?] = [
            addPrefix ? PiwikConstants.PrefixException : nil,
            fatal ? PiwikConstants.PrefixExceptionFatal : PiwikConstants.PrefixExceptionCaught,
            limitedDescription
        ]
        let actionName = components.strings().joined(separator: "/")
        
        // MARK: Is this really an action name?
        parametersDictionary[PiwikConstants.ParameterActionName] = actionName
    }
    
    init(withSocialAction action: String, forNetwork network: String, target: String?, addPrefix: Bool) {
        self.init()
        let components: [String?] = [
            addPrefix ? PiwikConstants.PrefixSocial : nil,
            network,
            action,
            target
        ]
        let actionName = components.strings().joined(separator: "/")
        
        // MARK: Is this really an action name?
        parametersDictionary[PiwikConstants.ParameterActionName] = actionName
    }
    
    init(withGoalId id: UInt, revenue: UInt) {
        self.init()
        parametersDictionary[PiwikConstants.ParameterGoalID] = "\(id)"
        parametersDictionary[PiwikConstants.ParameterRevenue] = "\(revenue)"
    }
    
    init(withSearchKeyword keyword: String, category: String?, hitcount: UInt?) {
        self.init()
        parametersDictionary[PiwikConstants.ParameterSearchKeyword] = keyword
        if let category = category {
            parametersDictionary[PiwikConstants.ParameterSearchCategory] = category
        }
        if let hitcount = hitcount {
            parametersDictionary[PiwikConstants.ParameterSearchNumberOfHits] = "\(hitcount)"
        }
    }
    
    init(withCampaign campaign: Campaign) {
        parametersDictionary[PiwikConstants.ParameterCampaignName] = campaign.name
        parametersDictionary[PiwikConstants.ParameterReferrer] = campaign.url.absoluteString
        if let keyword = campaign.keyword {
            parametersDictionary[PiwikConstants.ParameterCampaignKeyword] = keyword
        }
    }
    
    init(withTransaction transaction: Transaction) {
        parametersDictionary[PiwikConstants.ParameterTransactionIdentifier] = transaction.identifier
        parametersDictionary[PiwikConstants.ParameterRevenue] = "\(transaction.revenue)"
        parametersDictionary[PiwikConstants.ParameterTransactionTax] = "\(transaction.tax)"
        parametersDictionary[PiwikConstants.ParameterTransactionShipping] = "\(transaction.discount)"
        parametersDictionary[PiwikConstants.ParameterTransactionSubTotal] = "\(transaction.subTotal)"
        parametersDictionary[PiwikConstants.ParameterTransactionIdentifier] = "\(transaction.identifier)"
        do {
            let serializableItems = transaction.items.map({ $0.asArray() })
            let serializedItemData = try JSONSerialization.data(withJSONObject: serializableItems, options: [])
            if let serializedItems = String(data: serializedItemData, encoding: .utf8) {
                parametersDictionary[PiwikConstants.ParameterTransactionItems] = serializedItems
            }
        } catch {
            print("Unable to encode transaction items")
        }
    }
    
    init(withContentImpressionName name: String, piece: String?, target: String?) {
        self.init()
        parametersDictionary[PiwikConstants.ParameterContentName] = name
        if let piece = piece {
            parametersDictionary[PiwikConstants.ParameterContentPiece] = piece
        }
        if let target = target {
            parametersDictionary[PiwikConstants.ParameterContentTarget] = target
        }
    }
    
    init(withContentInteractionName name: String, piece: String?, target: String?) {
        self.init()
        parametersDictionary[PiwikConstants.ParameterContentName] = name
        if let piece = piece {
            parametersDictionary[PiwikConstants.ParameterContentPiece] = piece
        }
        if let target = target {
            parametersDictionary[PiwikConstants.ParameterContentTarget] = target
        }
        parametersDictionary[PiwikConstants.ParameterContentInteraction] = PiwikConstants.DefaultContentInteractionName
    }
    
}

extension Event: CustomStringConvertible {
    
    public var description : String {
        return parametersDictionary.description
    }
}
