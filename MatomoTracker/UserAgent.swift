//
//  UserAgent.swift
//  MatomoTracker
//
//  Created by Cornelius Horstmann on 04.10.20.
//  Copyright © 2020 Matomo. All rights reserved.
//

import Foundation

struct UserAgent {
    let application: Application
    let device: Device
    
    /// Returns the UserAgent string that can be used in an HTTP header
    /// Format: Darwin/<darwin version> (<platform>; <OS> <OS version>) MatomoTrackerSDK/<matomo version> <app name>/<app version>
    var stringValue: String {
        [
            "Darwin/\(device.darwinVersion ?? "Unknown-Version") (\(device.platform); \(device.operatingSystem) \(device.osVersion))",
            "MatomoTrackerSDK/\(MatomoTracker.sdkVersion)",
            "\(application.bundleName ?? "Unknown-App")/\(application.bundleShortVersion ?? "Unknown-Version")"
        ].joined(separator: " ")
    }
}
