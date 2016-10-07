//
//  PiwikTracker.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 07.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

enum CustomVariableScope: Int {
    case Visit
    case Screen
}

let PiwikSessionStartNotification: String = "PiwikSessionStartNotification"

public class PiwikTracker: NSObject {
    
    private static var _sharedInstance: PiwikTracker?
    public let siteID: String
    public let dispatcher: PiwikDispatcher
    
    // FIXME: handle those
    public var userID: String?
    public var prefixingEnabled: Bool = true
    public var debug: Bool = false
    public var optOut: Bool = false
    public var sampleRate: UInt8 = 100 {
        didSet {
            if sampleRate > 100 {
                // FIXME: ad a log warning here?
                sampleRate = 100
            }
        }
    }
    public var includeDefaultCustomVariable: Bool = true
    public var sessionStart: Bool = false // I can see this matches the backend concept, but shouldn't it better be a function? "restartSession" or "finishCurrentSession" or such?
    public var sessionTimeout: TimeInterval = 120
    
    public static var sharedInstance: PiwikTracker? {
        get { return _sharedInstance }
    }
    
    public class func sharedInstance(with siteId: String, baseURL: URL) -> PiwikTracker? {
        let lastPathComponent = baseURL.lastPathComponent
        // FIXME: add url cleanup (remove last component?)
        let dispatcher = defaultDispatcher(with: baseURL)
        self._sharedInstance = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
        return sharedInstance
    }
    
    public class func sharedInstance(with siteId: String, dispatcher: PiwikDispatcher) -> PiwikTracker? {
        self._sharedInstance = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
        return sharedInstance
    }
    
    private class func defaultDispatcher(with baseUrl: URL) -> PiwikDispatcher {
        // FIXME: return proper dispatcher
        return PiwikDebugDispatcher()
    }
    
    init(siteId: String, dispatcher: PiwikDispatcher) {
        self.siteID = siteId
        self.dispatcher = dispatcher
    }
    
    public func send(view: String) -> Bool {
        return send(views: [view])
    }
    
    public func send(screen: String) -> Bool {
        return false
    }
    
    public func send(views: [String]) -> Bool {
        if prefixingEnabled {
            let prefixed = [PiwikConstants.PrefixView] + views
            return send(components: prefixed)
        }
        return send(components: views)
    }
    
    private func send(components: [String]) -> Bool {
        let params = [
            PiwikConstants.ParameterActionName: components.joined(separator: "/"),
            PiwikConstants.ParameterURL: "" // [self generatePageURL:components];
        ]
        return queue(event: params)
    }
    
    private func queue(event: [String:String]) -> Bool {
        guard !optOut else { return true }
        guard sampleRate == 100 || sampleRate < UInt8(arc4random_uniform(101)) else { return true }
        
//        parameters = [self addPerRequestParameters:parameters];
//        parameters = [self addSessionParameters:parameters];
//        parameters = [self addStaticParameters:parameters];
        
        // FIXME: store the event for later transmission
        return false
    }
}
