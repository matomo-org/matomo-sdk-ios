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
internal struct Event {
    internal let uuid = NSUUID().uuidString
    
    /// The Date and Time the event occurred.
    /// api-key: h, m, s
    internal let date: Date
    
    /// The full URL for the current action. 
    internal let url: URL
    
    /// api-key: action_name
    internal let actionName: [String]
    
    /// Unique ID per visitor (device in this case). Should be
    /// generated upon first start and never changed after.
    /// api-key: _id
    internal let visitorId: String
    
    /// An optional user identifier such as email or username.
    /// api-key: uid
    internal let userId: String?
    
    /// The number of sessions of the current user.
    /// api-key: _idvc
    internal let sessionsCount: Int
    
    /// The timestamp of the previous visit.
    /// Discussion: Should this be now for the first request?
    /// api-key: _viewts
    internal let lastVisit: Date?
    
    /// The timestamp of the fist visit.
    /// Discussion: Should this be now for the first request?
    /// api-key: _idts
    internal let firstVisit: Date?
    
    /// The language of the device.
    /// Should be in the format of the Accept-Language HTTP header field.
    /// api-key: lang
    internal let language: String
    
    /// Should be set to true for the first event of a session.
    /// api-key: new_visit
    internal let isNewSesssion: Bool
    
    /// Currently only used for Campaigns
    /// api-key: urlref
    internal let referer: URL?
    
    /// api-key: _cvar
    //internal let customVariables: [CustomVariable]
}

