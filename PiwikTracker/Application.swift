#if os(OSX)
#elseif os(iOS)
import UIKit

internal struct Application {
    /// Creates an returns a new application object representing the current application
    static func makeCurrentApplication() ->  Application {
        let displayName = bundleDisplayNameForCurrentApplication()
        let name = bundleNameForCurrentApplication()
        let version = bundleVersionForCurrentApplication()
        let shortVersion = bundleShortVersionForCurrentApplication()
        return Application(bundleDisplayName: displayName, bundleName: name, bundleVersion: version, bundleShortVersion: shortVersion)
    }
    
    /// The name of your app as displayed on the homescreen i.e. "My App"
    let bundleDisplayName: String?
    
    /// The bundle name of your app i.e. "com.my-company.my-app"
    let bundleName: String?
    
    /// The bundle version a.k.a. build number as String i.e. "149"
    let bundleVersion: String?
    
    /// The app version as String i.e. "1.0.1"
    let bundleShortVersion: String?
    
    /// Returns the name of the app as displayed on the homescreen
    private static func bundleDisplayNameForCurrentApplication() -> String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    /// Returns the bundle name of the app
    private static func bundleNameForCurrentApplication() -> String? {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String
    }
    
    /// Returns the bundle version
    private static func bundleVersionForCurrentApplication() -> String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    /// Returns the app version
    private static func bundleShortVersionForCurrentApplication() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
#endif
