import Foundation
import MatomoTracker

extension MatomoTracker {
    static let shared: MatomoTracker = {
        let queue = UserDefaultsQueue(UserDefaults.standard, autoSave: true)
        let dispatcher = URLSessionDispatcher(baseURL: URL(string: "https://demo2.matomo.org/piwik.php")!)
        let matomoTracker = MatomoTracker(siteId: "23", queue: queue, dispatcher: dispatcher)
        // matomoTracker.userId = "userId"
        // matomoTracker.setCookie(cookie: "cookie1=value1; cookie2=value2")
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
