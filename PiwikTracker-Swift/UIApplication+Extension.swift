//
//  UIApplication+Extension.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 11.10.16.
//  Copyright © 2016 Mattias Levin. All rights reserved.
//

import UIKit

extension UIApplication {
    static var bundleDisplayName: String? {
        get {
            return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        }
    }
    static var bundleName: String? {
        get {
            return Bundle.main.infoDictionary?["bundleName"] as? String
        }
    }
    static var bundleVersion: String? {
        get {
            return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        }
    }
    static var appName: String {
        return bundleDisplayName ?? bundleName ?? "unknown"
    }
}
