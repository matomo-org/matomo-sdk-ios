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
        let tracker = PiwikTracker.sharedInstance(withSiteID: siteId, dispatcher: dispatcher)
        
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
                    let _ = tracker.sendView("_specView")
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
                    let _ = tracker.sendView("_specView")
                    expect(dispatcher.lastParameters).toEventuallyNot(beNil())
                    expect(dispatcher.lastParameters?["uid"]).toEventually(beNil())
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
                    tracker.optOut = false
                    let _ = tracker.sendView("_specView")
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
                    let _ = tracker.sendView("_specView")
                    let _ = tracker.dispatch()
                    let cvar = dispatcher.lastParameters!["_cvar"]!.data(using: .utf8)!
                    let json = try! JSONSerialization.jsonObject(with: cvar, options: []) as! [String:[String]]
                    expect(json["1"]).to(contain("Platform"))
                    expect(json["2"]).to(contain("OS version"))
                    expect(json["3"]).to(contain("App version"))
                }
                it("should not be possible to set a customVariable in the visit scope of index < 4") {
                    let setResult = tracker.setCustomVariable(forIndex: 3, name: "_spec_name", value: "_spec_value", scope: .Visit)
                    expect(setResult).to(beFalse())
                    let _ = tracker.sendView("_specView")
                    let _ = tracker.dispatch()
                    let cvar = dispatcher.lastParameters!["_cvar"]!.data(using: .utf8)!
                    let json = try! JSONSerialization.jsonObject(with: cvar, options: []) as! [String:[String]]
                    expect(json["3"]).toNot(contain("_spec_name"))
                }
            }
        }
        
        describe("prefixingEnabled") {
            context("with prefixing enabled") {
                let siteId = "prefixingEnabledTrue"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.prefixingEnabled = true
                it("should prefix views") {
                    let _ = tracker.sendView("_specView")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters!["action_name"]).to(equal("screen/_specView"))
                }
                it("should prefix exceptions") {
                    let _ = tracker.sendException(description: "_specException", fatal: false)
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters!["action_name"]).to(equal("exception/caught/_specException"))
                }
                it("should prefix social actions") {
                    let _ = tracker.sendSocial(action: "_specSocialAction", forNetwork: "_specSocialNetwork")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters!["action_name"]).to(equal("social/_specSocialNetwork/_specSocialAction"))
                }
            }
            context("with prefixing disabled") {
                let siteId = "prefixingEnabledFalse"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.prefixingEnabled = false
                it("should not prefix views") {
                    let _ = tracker.sendView("_specView")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters!["action_name"]).to(equal("_specView"))
                }
                it("should not prefix exceptions") {
                    let _ = tracker.sendException(description: "_specException", fatal: false)
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters!["action_name"]).to(equal("caught/_specException"))
                }
                it("should not prefix social actions") {
                    let _ = tracker.sendSocial(action: "_specSocialAction", forNetwork: "_specSocialNetwork")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters!["action_name"]).to(equal("_specSocialNetwork/_specSocialAction"))
                }
            }
        }
        
        describe("debug") {
            context("with debug enabled") {
                let siteId = "debugEnabledTrue"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.debug = true
                it("should skip dispatching") {
                    expect(tracker.debug).to(beTrue())
                    dispatcher.lastParameters = nil
                    let _ = tracker.sendView("_specView")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters).to(beNil())
                }
            }
            context("with debug disabled") {
                let siteId = "debugEnabledFalse"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.debug = false
                it("should not skip dispatching") {
                    dispatcher.lastParameters = nil
                    let _ = tracker.sendView("_specView")
                    let _ = tracker.dispatch()
                    expect(dispatcher.lastParameters).toNot(beNil())
                }
            }
        }
        
        describe("optOut") {
            it("should skip dispatching if optOut is true") {
                let siteId = "optOutTrue"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.optOut = true
                dispatcher.lastParameters = nil
                let _ = tracker.sendView("_specView")
                let _ = tracker.dispatch()
                expect(dispatcher.lastParameters).to(beNil())
                tracker.optOut = false // reset the optOut value again for the other tests
            }
            it("should not skip dispatching if optOut is false") {
                let siteId = "optOutFalse"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.optOut = false
                dispatcher.lastParameters = nil
                let _ = tracker.sendView("_specView")
                let _ = tracker.dispatch()
                expect(dispatcher.lastParameters).toNot(beNil())
            }
            it("should store and restore the value") {
                let siteId = "optOutTrue"
                let dispatcher = PiwikDispatcherStub()
                let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                tracker.optOut = true
                expect(tracker.optOut).to(beTrue())
                
                let newTracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
                expect(newTracker.optOut).to(beTrue())
                
                tracker.optOut = false
                expect(tracker.optOut).to(beFalse())
                expect(newTracker.optOut).to(beFalse())
            }
        }
        
        describe("sampleRate") {
            // I have no idea how to write a test for this
            // after all it all depends on chance
            // so if I calculate the percentage of skipped 
            // events, there still is the chance of all
            // events being skipped, or none
            it("should not be possible to set a sample rate higher than 100") {
                guard let tracker = PiwikTracker.sharedInstance else { return }
                let oldSampleRate = tracker.sampleRate
                tracker.sampleRate = 101
                expect(tracker.sampleRate).to(equal(100))
                tracker.sampleRate = oldSampleRate
            }
        }
        
        describe("sessionStart") {
            let siteId = "sessionStart"
            let dispatcher = PiwikDispatcherStub()
            let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
            it("should start a new session in the next request if set to true") {
                tracker.sessionStart = true
                let _ = tracker.sendView("_specView")
                let _ = tracker.dispatch()
                expect(dispatcher.lastParameters!["new_visit"]).to(equal("1"))
            }
            it("should only start a new session for the first request if set to true") {
                tracker.sessionStart = true
                let _ = tracker.sendView("_specView")
                let _ = tracker.dispatch()
                expect(dispatcher.lastParameters!["new_visit"]).to(equal("1"))
                expect(tracker.sessionStart).to(beFalse())
                let _ = tracker.sendView("_specView")
                let _ = tracker.dispatch()
                expect(dispatcher.lastParameters!["new_visit"]).to(beNil())
            }
        }
        
        describe("sessionTimeout") { }
        describe("dispatchInterval") { }
        
        describe("maxNumberOfEvents") {
            let siteId = "maxNumberOfEvents"
            let dispatcher = PiwikDispatcherStub()
            let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
            it("should prevent dispatching after the maximum number is exceeded") {
                let _ = tracker.dispatch()
                tracker.maxNumberOfQueuedEvents = 1
                let firstSuccess = tracker.sendView("_specView")
                expect(firstSuccess).to(beTrue())
                let secondSuccess = tracker.sendView("_specView")
                expect(secondSuccess).to(beFalse())
            }
        }
        
        describe("eventsPerRequest") { }
        
        describe("observe UIApplicationDidBecomeActiveNotification and UIApplicationWillResignActiveNotification") {
            // test if they are observed properly and if 
            // they are handeled accordingly
        }
        
        describe("dispatch") { }
        describe("deleteQueuedEvents") {
            let siteId = "maxNumberOfEvents"
            let dispatcher = PiwikDispatcherStub()
            let tracker = PiwikTracker(siteId: siteId, dispatcher: dispatcher)
            it("should delete all Events that are queued") {
                let _ = tracker.dispatch()
                let _ = tracker.sendView("_specView")
                tracker.deleteQueuedEvents()
                let _ = tracker.dispatch()
                expect(dispatcher.lastParameters).to(beNil())
            }
        }
        
        // TODO: implement all the send/set methods and validate that the proper parameters are set
        
        
    }
}
