//
//  AutoTracker.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 04.09.17.
//  Copyright © 2017 PIWIK. All rights reserved.
//

import Foundation
@testable import PiwikTracker

extension TrackerSpec {
    
    internal final class AutoTracker {
        
        let tracker: PiwikTracker
        let interval: TimeInterval
        var timer: Timer?
        
        init(tracker: PiwikTracker, trackingInterval: TimeInterval) {
            self.tracker = tracker
            self.interval = trackingInterval
        }
        
        @objc private func track() {
            tracker.queue(event: EventFixture.event())
        }
        
        func start() {
            self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(track), userInfo: nil, repeats: true)
        }
        
        func stop() {
            self.timer?.invalidate()
        }
        
    }
    
}
