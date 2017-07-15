//
//  Event.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 21.12.16.
//  Copyright © 2016 PIWIK. All rights reserved.
//

import Foundation

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
/// - dimension: For now we don't support dimension.
/// - UserAgent (ua) should be set in the dispatcher, right?
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
    
    /// api-key: _cvar
    //let customVariables: [CustomVariable]
    
    /// Event tracking
    /// https://piwik.org/docs/event-tracking/
    let eventCategory: String?
    let eventAction: String?
    let eventName: String?
    let eventValue: Float?
    
    let dimensions: [CustomDimension]
}
