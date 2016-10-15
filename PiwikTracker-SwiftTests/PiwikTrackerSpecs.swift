//
//  PiwikTrackerSpecs.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 09.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import Foundation

@testable import PiwikTrackerSwift
import Nimble
import Quick

class PiwikTrackerSpecs: QuickSpec {
    override func spec() {
        
        let siteId = "_specSiteId"
        let dispatcher = PiwikDispatcherStub()
        let tracker = PiwikTracker.sharedInstance(withSiteId: siteId, dispatcher: dispatcher)
        
        describe("initWithSiteID:dispatcher:") {
            let siteId = "testInitWithSiteIdAndDispatcherSiteId"
            let dispatcher = PiwikDispatcherStub()
            
            it("should be initializable") {
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                expect(tracker).toNot(beNil())
            }
            
            // pending
            //            it("should not be initializable with an empty siteid") {
            //                let tracker = PiwikTracker(siteId: "", dispatcher: dispatcher)
            //                expect(tracker).to(beNil())
            //            }
            
            it("should be instantiated with the correct properties") {
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                expect(tracker.siteID).to(equal(siteId))
            }
            
        }
        describe("sharedInstance") {
            it("should return the shared instance") {
                expect(PiwikTracker.sharedInstance).toNot(beNil())
            }
        }
        
        describe("userID") {
            it("should be nil per default") {
                let siteId = "testInitWithSiteIdAndDispatcherSiteId"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                expect(tracker.userID).to(beNil())
            }
            context("with a userID set") {
                let userId = "_specUserId"
                let siteId = "trackerWithUserIdSet"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.userID = userId
                tracker.dispatchInterval = 0
                it("should save the value") {
                    expect(tracker.userID).to(equal(userId))
                }
                it("should set the userid as the uid parameter") {
                    let _ = tracker.send(view: "_speckView")
                    expect(dispatcher.lastParameters?["uid"]).toEventually(equal(userId))
                }
            }
            context("with the userID set to nil") {
                let siteId = "trackerWithUserIdSetToNil"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.userID = nil
                tracker.dispatchInterval = 0
                it("should save the value") {
                    expect(tracker.userID).to(beNil())
                }
                it("should not set the userid as the uid parameter") {
                    dispatcher.lastParameters = nil
                    let _ = tracker.send(view: "_speckView")
                    expect(dispatcher.lastParameters).toEventuallyNot(beNil())
                    expect(dispatcher.lastParameters?["uid"]).toEventually(beNil())
                }
            }
        }
        
        describe("optOut") {
            it("should be false per default") {
                let siteId = "testOptOut"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                expect(tracker.optOut).to(beFalse())
            }
            context("with the optout to be false") {
                let siteId = "trackerWithOptOutFalse"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.optOut = false
                it("should dispatch events") {
                    let _ = tracker.send(view: "_speckView")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters).toNot(beNil())
                }
            }
            context("with the optout to be true") {
                let siteId = "trackerWithOptOutTrue"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.optOut = true
                it("should not dispatch events") {
                    let _ = tracker.send(view: "_speckView")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters).to(beNil())
                }
            }
        }
        
        describe("includeDefaultCustomVariable") {
            it("should be true per default") {
                let siteId = "testIncludeDefaultCustomVariable"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                expect(tracker.includeDefaultCustomVariable).to(beTrue())
            }
            context("with the includeDefaultCustomVariable to be false") {
                let siteId = "trackerWithOptOutFalse"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.includeDefaultCustomVariable = false
                it("shoud set the default custom variables") {
                    let _ = tracker.send(view: "_speckView")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters?["_cvar"]).to(equal("{}"))
                }
            }
            context("with the includeDefaultCustomVariable to be true") {
                let siteId = "trackerWithOptOutFalse"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.includeDefaultCustomVariable = true
                it("shoud set the default custom variables") {
                    let _ = tracker.send(view: "_speckView")
                    let _ = tracker.dispatch()
                    let cvar = dispatcher.lastParameters!["_cvar"]!.data(using: .utf8)!
                    let json = try! JSONSerialization.jsonObject(with: cvar, options: []) as! [String:[String]]
                    expect(json["1"]).to(contain("Platform"))
                    expect(json["2"]).to(contain("OS version"))
                    expect(json["3"]).to(contain("App version"))
                }
            }
        }
        
    }
}
