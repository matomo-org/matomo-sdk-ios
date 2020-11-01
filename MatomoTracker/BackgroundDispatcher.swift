//
//  BackgroundDispatcher.swift
//  MatomoTracker
//
//  Created by Cornelius Horstmann on 01.11.20.
//  Copyright © 2020 Matomo. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit

public class BackgroundDispatcher: Dispatcher {
    
    private let underlyingDispatcher: Dispatcher
    private weak var application: UIApplication?
    
    public init(underlyingDispatcher: Dispatcher, application: UIApplication) {
        self.underlyingDispatcher = underlyingDispatcher
        self.application = application
    }
    
    public var baseURL: URL {
        get {
            underlyingDispatcher.baseURL
        }
    }
    
    public func send(events: [Event], completion: @escaping (Result<Void, Error>) -> Void) {
        performBackgroundTask(withName: "Matomo") { [weak self] backgroundCompletion in
            self?.underlyingDispatcher.send(events: events) {
                backgroundCompletion()
                completion($0)
            }
        }
    }
    
    private func performBackgroundTask(withName name: String, closure: @escaping (_ completion: @escaping () -> Void) -> Void) {
        guard let application = application else {
            return closure() {}
        }
        let identifier = application.beginBackgroundTask(withName: name) {
            // Todo: Better logging
            print("expired")
        }
        closure { [weak application] in
            application?.endBackgroundTask(identifier)
        }
    }
}

#endif
