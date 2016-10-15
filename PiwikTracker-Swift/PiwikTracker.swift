//
//  PiwikTracker.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 07.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

public enum CustomVariableScope: Int {
    case Visit
    case Screen
}

let PiwikSessionStartNotification: String = "PiwikSessionStartNotification"


public class PiwikTracker: NSObject {
    
    internal static var _sharedInstance: PiwikTracker?
    public let siteID: String
    public let dispatcher: PiwikDispatcher
    private let eventQueue: EventQueue
    
    // FIXME: handle those
    public var userID: String? = nil
    public var prefixingEnabled: Bool = true
    public var debug: Bool = false
    public var optOut: Bool = false // FIXME: get this from the userdefaults
    public var sampleRate: UInt8 = PiwikConstants.DefaultSampleRate {
        didSet {
            if sampleRate > 100 {
                // FIXME: ad a log warning here?
                sampleRate = 100
            }
        }
    }
    public var includeDefaultCustomVariable: Bool = true
    public var sessionStart: Bool = true // I can see this matches the backend concept, but shouldn't it better be a function? "restartSession" or "finishCurrentSession" or such?
    public var sessionTimeout: TimeInterval = PiwikConstants.DefaultSessionTimeout
    public var dispatchInterval: TimeInterval = PiwikConstants.DefaultDispatchTimer
    public var maxNumberOfQueuedEvents: UInt32 = PiwikConstants.DefaultMaxNumberOfStoredEvents
    public var eventsPerRequest: UInt8 = PiwikConstants.DefaultNumberOfEventsPerRequest
    
    init(siteId: String, dispatcher: PiwikDispatcher) {
        self.siteID = siteId
        self.dispatcher = dispatcher
        
        // FIXME: add a persistent EventQueue
        self.eventQueue = EventQueueVolatile()
        
        // start dispatch timer
        // observe UIApplicationDidBecomeActiveNotification and UIApplicationWillResignActiveNotification
    }
    
    func queue(event: Event) -> Bool {
        guard !optOut else { return true }
        guard sampleRate == 100 || sampleRate < UInt8(arc4random_uniform(101)) else { return true }
        guard eventQueue.eventCount < maxNumberOfQueuedEvents else {
            debugPrint("Tracker reach maximum number of queued events")
            return true // should we better return false?
        }
        
        var mutatedEvent = event
        
        // FIXME: add those special parameters
        //        parameters = [self addPerRequestParameters:parameters];
        //        parameters = [self addSessionParameters:parameters];
        //        parameters = [self addStaticParameters:parameters];
        
        mutatedEvent.setParameters(fromTracker: self)
        mutatedEvent.setParameters(fromUserDefaults: PiwikUserDefaults.standard)
        
        eventQueue.storeEvent(event: mutatedEvent) {
            if dispatchInterval == 0 {
                DispatchQueue.main.async(execute: { [unowned self] in
                    let _ = self.dispatch()
                })
            }
        }
        return false
    }
    
    public func dispatch() -> Bool {
        guard !dispatcherRunning else { return true }
        dispatcherRunning = true
        dispatchNextBatch()
        return true
    }
    
    
    private func dispatchNextBatch() {
        eventQueue.events(withLimit: eventsPerRequest) { (entityIds, events, hasMore) in
            if events.count == 0 {
                finishDispatching()
            } else {
                let success = {
                    if hasMore {
                        self.eventQueue.deleteEvents(withEntityIds: entityIds)
                        self.dispatchNextBatch()
                    } else {
                        self.finishDispatching()
                    }
                }
                let error:(Bool)->() = { shouldContinue in
                    if shouldContinue {
                        self.dispatchNextBatch()
                    } else {
                        self.finishDispatching()
                    }
                }
                if events.count == 1 {
                    self.dispatcher.send(event: events.first!, success: success, failure: error)
                } else {
                    self.dispatcher.send(events: events, success: success, failure: error)
                }
            }
        }
    }
    
    private func finishDispatching() {
        dispatcherRunning = false
        startDispatchTimer()
    }
    
    internal var appDidEnterBackground: Date?
    
    internal var dispatcherRunning = false
    internal var dispatchTimer: Timer?
}

// MARK: dispatcher
internal extension PiwikTracker {
    func startDispatchTimer() {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.stopDispatchTimer()
            if self.dispatchInterval > 0 {
                self.dispatchTimer = Timer.scheduledTimer(timeInterval: self.dispatchInterval, target: self, selector: #selector(self.dispatch), userInfo: nil, repeats: false)
            }
            })
    }
    
    func stopDispatchTimer() {
        if let dispatchTimer = dispatchTimer {
            dispatchTimer.invalidate()
            self.dispatchTimer = nil
        }
    }
}

// MARK: sharedInstance
extension PiwikTracker {
    
    class func defaultDispatcher(withBaseUrl baseUrl: URL) -> PiwikDispatcher {
        // FIXME: return proper dispatcher
        return PiwikDebugDispatcher()
    }
    
    public static var sharedInstance: PiwikTracker? {
        get { return _sharedInstance }
    }
    
    public class func sharedInstance(withSiteId siteId: String, baseURL: URL) -> PiwikTracker? {
        let dispatcher: PiwikDispatcher
        let lastPathComponent = baseURL.lastPathComponent
        if lastPathComponent == "piwik.php" || lastPathComponent == "piwik-proxy.php" {
            dispatcher = defaultDispatcher(withBaseUrl: baseURL.deletingPathExtension())
        } else {
            dispatcher = defaultDispatcher(withBaseUrl: baseURL)
        }
        self._sharedInstance = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
        return sharedInstance
    }
    
    public class func sharedInstance(withSiteId siteId: String, dispatcher: PiwikDispatcher) -> PiwikTracker? {
        self._sharedInstance = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
        return sharedInstance
    }
}

// MARK: sending events
extension PiwikTracker {
    public func send(view: String) -> Bool {
        return send(views: [view])
    }
    
    public func send(views: [String]) -> Bool {
        let event = Event(withViews: views, addPrefix: prefixingEnabled)
        return queue(event: event)
    }
    
    public func send(outlink url: String) -> Bool {
        let event = Event(withOutlink: url)
        return queue(event: event)
    }
    
    public func send(download url: String) -> Bool {
        let event = Event(withDownload: url)
        return queue(event: event)
    }
    
    public func sendEvent(withCategory category: String, action: String, name: String? = nil, value: String? = nil) -> Bool {
        let event = Event(withCategory: category, action: action, name: name, value: value)
        return queue(event: event)
    }
    
    public func sendException(withDescription description: String, fatal: Bool) -> Bool {
        let event = Event(withException: description, fatal: fatal, addPrefix: prefixingEnabled)
        return queue(event: event)
    }
    
    public func sendSocial(action: String, forNetwork network: String, target: String? = nil) -> Bool {
        let event = Event(withSocialAction: action, forNetwork: network, target: target, addPrefix: prefixingEnabled)
        return queue(event: event)
    }
    
    public func sendGoal(withId id: UInt, revenue: UInt) -> Bool {
        let event = Event(withGoalId: id, revenue: revenue)
        return queue(event: event)
    }
    
    public func sendSearch(withKeyword keyword: String, category: String?, hitcount: UInt?) -> Bool {
        let event = Event(withSearchKeyword: keyword, category: category, hitcount: hitcount)
        return queue(event: event)
    }
    
    // FIXME: implement Transactions
//    public func sendTransaction()
    
    public func sendCampaign(_ campaign: Campaign) -> Bool {
        let campaignParameters = [
            PiwikConstants.ParameterCampaignName: campaign.name,
            PiwikConstants.ParameterCampaignKeyword: campaign.keyword,
            PiwikConstants.ParameterReferrer: campaign.url.absoluteString
        ]
        // FIXME: handle these campaignParameters
        // self.campaignParameters = [NSDictionary dictionaryWithDictionary:parameters];
        return false
    }
    
    public func sendContentImpression(withName name: String, piece: String?, target: String?) -> Bool {
        let event = Event(withContentImpressionName: name, piece: piece, target: target)
        return queue(event: event)
    }
    
    public func sendContentInteraction(withName name: String, piece: String?, target: String?) -> Bool {
        let event = Event(withContentInteractionName: name, piece: piece, target: target)
        return queue(event: event)
    }
    
    public func setCustomVariable(forIndex index: UInt, name: String, value: String, scope: CustomVariableScope) -> Bool {
        if includeDefaultCustomVariable && scope == .Visit && index <= 3 {
            debugPrint("Custom variable index conflicting with default indexes used by the SDK. Change index or turn off default default variables")
            return false
        }
        
        let customVariable = CustomVariable(index: index, name: name, value: value)
//        switch scope {
//        case .Screen:
//        case .Visit:
//        }
        // FIXME: add the variable to the visit/screen customVariables
        // return true
        return false
    }
    
    public func send(screen: String) -> Bool {
        return false
    }
}
