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
    
    var stringValue: String {
        "\(application.bundleDisplayName ?? "Unknown-App")/\(application.bundleShortVersion ?? "Unknown-Version") \(device.platform) iOS/\(device.osVersion) MatomoTrackerIOSSDK/\(application.matomoSDKVersion ?? "Unknown-Version") Darwin/\(device.darwinVersion ?? "Unknown-Version")"
    }
}
