//
//  PiwikTracker+SharedInstance.swift
//  ios
//
//  Created by Cornelius Horstmann on 14.12.17.
//  Copyright © 2017 Mattias Levin. All rights reserved.
//

import Foundation
import MatomoTracker

extension MatomoTracker {
    static let shared: MatomoTracker = {
        let matomoTracker = MatomoTracker(siteId: "23", baseURL: URL(string: "https://demo2.matomo.org/piwik.php")!)
        matomoTracker.logger = DefaultLogger(minLevel: .info)
        matomoTracker.migrateFromFourPointFourSharedInstance()
        return matomoTracker
    }()
    
    private func migrateFromFourPointFourSharedInstance() {
        guard !UserDefaults.standard.bool(forKey: "migratedFromFourPointFourSharedInstance") else { return }
        copyFromOldSharedInstance()
        UserDefaults.standard.set(true, forKey: "migratedFromFourPointFourSharedInstance")
    }
}
