//
//  PiwikTracker.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 07.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

public class PiwikTracker: NSObject {
    static var SessionStartNotification: String =  {
        return "PiwikSessionStartNotification"
    }()
    
    internal static var _sharedInstance: PiwikTracker?
    public let siteID: String
    public let dispatcher: PiwikDispatcher
    private let debugDispatcher = PiwikDebugDispatcher()
    private var usedDispatcher: PiwikDispatcher {
        if debug {
            return debugDispatcher
        } else {
            return dispatcher
        }
    }
    private let eventQueue: EventQueue
    
    // FIXME: handle those
    public var userID: String? = nil
    public var prefixingEnabled: Bool = true
    public var debug: Bool = false
    public var optOut: Bool {
        get {
            return PiwikUserDefaults.standard.optOut
        }
        set {
            print("setting optOut to \(newValue)")
            PiwikUserDefaults.standard.optOut = newValue
        }
    }
    public var sampleRate: UInt8 = PiwikConstants.DefaultSampleRate {
        didSet {
            sampleRate = [100, sampleRate].min()!
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
    
    internal func queue(event: Event) -> Bool {
        guard !optOut else { return true }
        guard sampleRate == 100 || sampleRate < UInt8(arc4random_uniform(101)) else { return true }
        guard eventQueue.eventCount < maxNumberOfQueuedEvents else {
            print("Tracker reach maximum number of queued events")
            return false
        }
        
        var mutatedEvent = event
        
        // FIXME: add those special parameters
        //        parameters = [self addPerRequestParameters:parameters];
        //        parameters = [self addSessionParameters:parameters];
        //        parameters = [self addStaticParameters:parameters];
        
        mutatedEvent.setParameters(fromUserDefaults: PiwikUserDefaults.standard, andTracker: self)
        sessionStart = false // just set it to false
        
        eventQueue.storeEvent(event: mutatedEvent) {
            if dispatchInterval == 0 {
                DispatchQueue.main.async(execute: { [unowned self] in
                    let _ = self.dispatch()
                    })
            }
        }
        return true
    }
    
    public func dispatch() -> Bool {
        guard !dispatcherRunning else { return true }
        dispatcherRunning = true
        dispatchNextBatch()
        return true
    }
    
    public func deleteQueuedEvents() {
        eventQueue.deleteAllEvents()
    }
    
    private func dispatchNextBatch() {
        eventQueue.events(withLimit: eventsPerRequest) { (entityIds, events, hasMore) in
            if events.count == 0 {
                finishDispatching()
            } else {
                let success = {
                    self.eventQueue.deleteEvents(withUUIDs: entityIds)
                    if hasMore {
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
                    self.usedDispatcher.send(event: events.first!, success: success, failure: error)
                } else {
                    self.usedDispatcher.send(events: events, success: success, failure: error)
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
    
    public class func sharedInstance(withSiteID siteID: String, baseURL: URL) -> PiwikTracker? {
        let dispatcher: PiwikDispatcher
        let lastPathComponent = baseURL.lastPathComponent
        if lastPathComponent == "piwik.php" || lastPathComponent == "piwik-proxy.php" {
            dispatcher = defaultDispatcher(withBaseUrl: baseURL.deletingPathExtension())
        } else {
            dispatcher = defaultDispatcher(withBaseUrl: baseURL)
        }
        self._sharedInstance = PiwikTracker(siteId: siteID, dispatcher: dispatcher)
        return sharedInstance
    }
    
    public class func sharedInstance(withSiteID siteID: String, dispatcher: PiwikDispatcher) -> PiwikTracker? {
        self._sharedInstance = PiwikTracker(siteId: siteID, dispatcher: dispatcher)
        return sharedInstance
    }
}

// MARK: sending events
extension PiwikTracker {
    public func sendView(_ view: String) -> Bool {
        return sendViews([view])
    }
    
    public func sendViews(_ views: [String]) -> Bool {
        let event = Event(withViews: views, addPrefix: prefixingEnabled)
        return queue(event: event)
    }
    
    public func sendOutlink(url: String) -> Bool {
        let event = Event(withOutlink: url)
        return queue(event: event)
    }
    
    public func sendDownload(url: String) -> Bool {
        let event = Event(withDownload: url)
        return queue(event: event)
    }
    
    public func sendEvent(category: String, action: String, name: String? = nil) -> Bool {
        let event = Event(withCategory: category, action: action, name: name, value: nil)
        return queue(event: event)
    }
    
    public func sendEvent(category: String, action: String, name: String? = nil, value: Float) -> Bool {
        let event = Event(withCategory: category, action: action, name: name, value: value)
        return queue(event: event)
    }
    
    public func sendException(description: String, fatal: Bool) -> Bool {
        let event = Event(withException: description, fatal: fatal, addPrefix: prefixingEnabled)
        return queue(event: event)
    }
    
    public func sendSocial(action: String, forNetwork network: String, target: String? = nil) -> Bool {
        let event = Event(withSocialAction: action, forNetwork: network, target: target, addPrefix: prefixingEnabled)
        return queue(event: event)
    }
    
    public func sendGoal(id: UInt, revenue: UInt) -> Bool {
        let event = Event(withGoalId: id, revenue: revenue)
        return queue(event: event)
    }
    
    public func sendSearch(keyword: String, category: String?) -> Bool {
        let event = Event(withSearchKeyword: keyword, category: category, hitcount: nil)
        return queue(event: event)
    }
    
    public func sendSearch(keyword: String, category: String?, hitcount: UInt) -> Bool {
        let event = Event(withSearchKeyword: keyword, category: category, hitcount: hitcount)
        return queue(event: event)
    }
    
    public func sendTransaction(_ transaction: Transaction) -> Bool {
        let event = Event(withTransaction: transaction)
        return queue(event: event)
    }
    
    public func sendCampaign(url: URL) -> Bool {
        guard let campaign = Campaign(url) else { return false }
        return sendCampaign(campaign)
    }
    
    public func sendCampaign(_ campaign: Campaign) -> Bool {
        let event = Event(withCampaign: campaign)
        return queue(event: event)
    }
    
    public func sendContentImpression(name: String, piece: String?, target: String?) -> Bool {
        let event = Event(withContentImpressionName: name, piece: piece, target: target)
        return queue(event: event)
    }
    
    public func sendContentInteraction(name: String, piece: String?, target: String?) -> Bool {
        let event = Event(withContentInteractionName: name, piece: piece, target: target)
        return queue(event: event)
    }
    
    public func setCustomVariable(forIndex index: UInt, name: String, value: String, scope: CustomVariableScope) -> Bool {
        let customVariable = CustomVariable(index: index, name: name, value: value, scope: scope)
        return setCustomVariable(customVariable)
    }
    
    func setCustomVariable(_ customVariable: CustomVariable) -> Bool {
        if includeDefaultCustomVariable && customVariable.scope == .Visit && customVariable.index <= 3 {
            print("Custom variable index conflicting with default indexes used by the SDK. Change index or turn off default default variables")
            return false
        }
        // FIXME: implement me
        return false
    }
    
    public func send(screen: String) -> Bool {
        return false
    }
}
