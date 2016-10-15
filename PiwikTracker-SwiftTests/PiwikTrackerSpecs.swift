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
        
        
    }
}
