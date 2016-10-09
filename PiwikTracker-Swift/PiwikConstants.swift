//
//  PiwikConstants.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 07.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

struct PiwikConstants {
    
    static let ParameterSiteID = "idsite"
    static let ParameterRecord = "rec"
    static let ParameterAPIVersion = "apiv"
    static let ParameterScreenReseloution = "res"
    static let ParameterHours = "h"
    static let ParameterMinutes = "m"
    static let ParameterSeconds = "s"
    static let ParameterDateAndTime = "cdt"
    static let ParameterActionName = "action_name"
    static let ParameterURL = "url"
    static let ParameterVisitorID = "_id"
    static let ParameterUserID = "uid"
    static let ParameterVisitScopeCustomVariables = "_cvar"
    static let ParameterScreenScopeCustomVariables = "cvar"
    static let ParameterRandomNumber = "r"
    static let ParameterFirstVisitTimestamp = "_idts"
    static let ParameterPreviousVisitTimestamp = "_viewts"
    static let ParameterTotalNumberOfVisits = "_idvc"
    static let ParameterGoalID = "idgoal"
    static let ParameterRevenue = "revenue"
    static let ParameterSessionStart = "new_visit"
    static let ParameterLanguage = "lang"
    static let ParameterLatitude = "lat"
    static let ParameterLongitude = "long"
    static let ParameterSearchKeyword = "search"
    static let ParameterSearchCategory = "search_cat"
    static let ParameterSearchNumberOfHits = "search_count"
    static let ParameterLink = "link"
    static let ParameterDownload = "download"
    static let ParameterSendImage = "send_image"
    // Ecommerce
    static let ParameterTransactionIdentifier = "ec_id"
    static let ParameterTransactionSubTotal = "ec_st"
    static let ParameterTransactionTax = "ec_tx"
    static let ParameterTransactionShipping = "ec_sh"
    static let ParameterTransactionDiscount = "ec_dt"
    static let ParameterTransactionItems = "ec_items"
    // Campaign
    static let ParameterReferrer = "urlref"
    static let ParameterCampaignName = "_rcn"
    static let ParameterCampaignKeyword = "_rck"
    // Events
    static let ParameterEventCategory = "e_c"
    static let ParameterEventAction = "e_a"
    static let ParameterEventName = "e_n"
    static let ParameterEventValue = "e_v"
    // Content impression
    static let ParameterContentName = "c_n"
    static let ParameterContentPiece = "c_p"
    static let ParameterContentTarget = "c_t"
    static let ParameterContentInteraction = "c_i"
    
    // Piwik default parmeter values
    static let DefaultRecordValue = "1"
    static let DefaultAPIVersionValue = "1"
    static let DefaultContentInteractionName = "tap"
    
    // Default values
    static let DefaultSessionTimeout = TimeInterval(120)
    static let DefaultDispatchTimer = TimeInterval(120)
    static let DefaultMaxNumberOfStoredEvents = UInt32(500)
    static let DefaultSampleRate = UInt8(100)
    static let DefaultNumberOfEventsPerRequest = UInt8(20)
    
    static let ExceptionDescriptionMaximumLength = UInt(50)
    
    // Page view prefix values
    static let PrefixView = "screen"
    static let PrefixEvent = "event"
    static let PrefixException = "exception"
    static let PrefixExceptionFatal = "fatal"
    static let PrefixExceptionCaught = "caught"
    static let PrefixSocial = "social"
    
    // Incoming campaign URL parameters
    static let URLCampaignName = "pk_campaign"
    static let URLCampaignKeyword = "pk_kwd"
    
    // Notifications
    static let NotificationSessionStart = "PiwikSessionStartNotification"
    
    // User default keys
    // The key withh include the site id in order to support multiple trackers per application
    static let UserDefaultTotalNumberOfVisitsKey = "PiwikTotalNumberOfVistsKey"
    static let UserDefaultCurrentVisitTimestampKey = "PiwikCurrentVisitTimestampKey"
    static let UserDefaultPreviousVistsTimestampKey = "PiwikPreviousVistsTimestampKey"
    static let UserDefaultFirstVistsTimestampKey = "PiwikFirstVistsTimestampKey"
    static let UserDefaultVisitorIDKey = "PiwikVisitorIDKey"
    static let UserDefaultOptOutKey = "PiwikOptOutKey"
}
