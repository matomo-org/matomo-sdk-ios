//
//  Event.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 21.12.16.
//  Copyright © 2016 PIWIK. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents an event of any kind.
///
/// - Note: Should we store the resolution in the Event (cleaner) or add it before transmission (smaller)?
/// - Todo: 
///     - Add Campaign Parameters: _rcn, _rck
///     - Add Action info
///     - Event Tracking info
///     - Add Content Tracking info
///     - Add Ecommerce info
///
/// # Key Mapping:
/// Most properties represent a key defined at: [Tracking HTTP API](https://developer.piwik.org/api-reference/tracking-api). Keys that are not supported for now are:
///
/// - idsite, rec, rand, apiv, res, cookie,
/// - All Plugins: fla, java, dir, qt, realp, pdf, wma, gears, ag
/// - cid: We will use the uid instead of the cid.
public struct Event {
    let siteId: String
    let uuid: NSUUID
    let visitor: Visitor
    let session: Session
    
    /// The Date and Time the event occurred.
    /// api-key: h, m, s
    let date: Date
    
    /// The full URL for the current action. 
    /// api-key: url
    let url: URL
    
    /// api-key: action_name
    let actionName: [String]
    
    /// The language of the device.
    /// Should be in the format of the Accept-Language HTTP header field.
    /// api-key: lang
    let language: String
    
    /// Should be set to true for the first event of a session.
    /// api-key: new_visit
    let isNewSession: Bool
    
    /// Currently only used for Campaigns
    /// api-key: urlref
    let referer: URL?
    let screenResolution : CGSize = Device.makeCurrentDevice().screenSize
    /// api-key: _cvar
    //let customVariables: [CustomVariable]
    
    /// Event tracking
    /// https://piwik.org/docs/event-tracking/
    let eventCategory: String?
    let eventAction: String?
    let eventName: String?
    let eventValue: Float?
    
    let dimensions: [CustomDimension]
    
    let customTrackingParameters: [String:String]
}

extension Event {
    public init(tracker: PiwikTracker, action: [String], url: URL? = nil, referer: URL? = nil, eventCategory: String? = nil, eventAction: String? = nil, eventName: String? = nil, eventValue: Float? = nil, customTrackingParameters: [String:String] = [:]) {
        let url = url ?? URL(string: "http://example.com")!.appendingPathComponent(action.joined(separator: "/"))
        self.siteId = tracker.siteId
        self.uuid = NSUUID()
        self.visitor = tracker.visitor
        self.session = tracker.session
        self.date = Date()
        self.url = url
        self.actionName = action
        self.language = Locale.httpAcceptLanguage
        self.isNewSession = tracker.nextEventStartsANewSession
        self.referer = referer
        self.eventCategory = eventCategory
        self.eventAction = eventAction
        self.eventName = eventName
        self.eventValue = eventValue
        self.dimensions = tracker.dimensions
        self.customTrackingParameters = customTrackingParameters
    }
}
