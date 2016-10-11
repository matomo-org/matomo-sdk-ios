//
//  Event.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 11.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation
import UIKit

// the parameters are directly mapped from http://developer.piwik.org/api-reference/tracking-api
struct Event {
    let siteId: String
    let url: URL
    
    let actionName: String?
    let visitorId: String?
    // the rand, apiv and record parameter should be generated/set by the dispatcher
    
    // MARK: Optional User info
    let visitCustomVariables: String? // should this be in another format?
    let totalNumberOfVisits: UInt32?
    let previousVisit: Date?
    let firstVisit: Date?
    
    let campaignName: String?
    let campaignKeyword: String?
    
    let resolution: CGSize?
    let eventTime: Date?
    
    let customUserAgent: String?
    let language: String?
    let userId: String?
    
    let newVisit: Bool = false
    
    // dimensions?
    
    // MARK: Optional Action info
    let pageCustomVariables: String? // should this be in another format?
    let link: URL? // set the url to the same value
    let download: URL? // set the url to the same
    
    let searchKeyword: String?
    let searchCategory: String?
    let searchResultCount: UInt32?
    
    let pageViewIdentifier: String? // currently not implemented
    
    let goalId: String?
    let revenue: UInt32?
    
    let pageGenerationDuration: TimeInterval? // maybe to check the performance on different devices?
    // skipping the charset
    
    // MARK: Optional Event Tracking info
    let eventCategory: String?
    let eventAction: String?
    let eventName: String?
    let eventValue: UInt32? // unsigned? float?
    
    // MARK: Optional Content Tracking info
    let contentName: String?
    let contentPiece: String?
    let contentTarget: String?
    let contentInteraction: String?
    
    // MARK: Optional Ecommerce info
    // should we put all this in a "Transaction" object?
    let transactionIdentifier: String?
    let transactionItems: String? // FIXME: here should be items
    let transactionSubtotal: UInt32? // int or better float?
    let transactionTax: UInt32? // or better float?
    let transactionShipping: UInt32?
    let transactionDiscount: UInt32?
    let lastTransaction: Date?
    
    // for now i am skipping all the token_auth parameters
    
    // the send_image parameter should be set by the Dispatcher aswell
    
    init(tracker: PiwikTracker, userDefaults: PiwikUserDefaults) {
        siteId = tracker.siteID
        url = URL(string: "http://piwik.org")! // FIXME
        visitorId = userDefaults.clientId(withKeyPrefix: siteId)
    }
    
    var parametersDictionary: [String:String] {
        get {
            return Dictionary.removeOptionals(dictionary: [
                PiwikConstants.ParameterSiteID:siteId
                ])
        }
    }
}



