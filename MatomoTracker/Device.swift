import Foundation

final public class Device: NSObject {
    /// Creates an returns a new device object representing the current device
    @objc public static func makeCurrentDevice() ->  Device {
        let platform = currentPlatform()
        let operatingSystem = operatingSystemForCurrentDevice()
        let os = osVersionForCurrentDevice()
        let screenSize = screenSizeForCurrentDevice()
        let nativeScreenSize = nativeScreenSizeForCurrentDevice()
        let darwinVersion = darwinVersionForCurrentDevice()
        return Device(platform: platform,
                      operatingSystem: operatingSystem,
                      osVersion: os,
                      screenSize: screenSize,
                      nativeScreenSize: nativeScreenSize,
                      darwinVersion: darwinVersion)
    }
    
    /// The platform name of the device i.e. "iPhone1,1" or "iPad3,6"
    @objc public let platform: String
    
    @objc public let operatingSystem: String
    
    /// The version number of the OS as String i.e. "1.2" or "9.4"
    @objc public let osVersion: String
    
    /// The screen size
    @objc public let screenSize: CGSize
    
    /// The native screen size
    /// Will be CGSize.zero if the value is not defined on the running platorm.
    @objc public let nativeScreenSize: CGSize
    
    /// The darwin version as fetched from utsname()
    @objc public let darwinVersion: String?

    required public init(platform: String, operatingSystem: String, osVersion: String, screenSize: CGSize, nativeScreenSize: CGSize? = nil, darwinVersion: String? = nil) {
        self.platform = platform
        self.operatingSystem = operatingSystem
        self.osVersion = osVersion
        self.screenSize = screenSize
        self.nativeScreenSize = nativeScreenSize != nil ? nativeScreenSize! : CGSize.zero
        self.darwinVersion = darwinVersion

        super.init()
    }
}

extension Device {
    /// The platform name of the current device i.e. "iPhone1,1" or "iPad3,6"
    private static func currentPlatform() -> String  {
        #if targetEnvironment(simulator)
        return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "x86_64"
        #else
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0,  count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
        #endif
    }
    
    private static func darwinVersionForCurrentDevice() -> String? {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters)
    }
}

#if os(OSX)
    import AppKit
    extension Device {
        internal static func operatingSystemForCurrentDevice() -> String {
            // Instead of the "correct" macOS, we need to return "Mac OS X" here
            // to be compatible with the detection.
            // See: https://devicedetector.lw1.at
            return "Mac OS X"
        }
        
        /// Returns the version number of the current OS as String i.e. "1.2" or "9.4"
        internal static func osVersionForCurrentDevice() -> String  {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        }
        
        // Returns the screen size in points
        internal static func screenSizeForCurrentDevice() ->  CGSize {
            guard let mainScreen = NSScreen.main else { return CGSize.zero }
            return mainScreen.visibleFrame.size
        }
        
        // Returns the screen size in pixels
        internal static func nativeScreenSizeForCurrentDevice() ->  CGSize? {
            return nil
        }
    }
#elseif os(iOS) || os(tvOS)
    import UIKit
    extension Device {
        internal static func operatingSystemForCurrentDevice() -> String {
            #if os(iOS)
            return "iOS"
            #elseif os(tvOS)
            return "tvOS"
            #endif
        }
        
        /// Returns the version number of the current OS as String i.e. "1.2" or "9.4"
        internal static func osVersionForCurrentDevice() -> String  {
            return UIDevice.current.systemVersion
        }
        
        // Returns the screen size in points
        internal static func screenSizeForCurrentDevice() ->  CGSize {
            let bounds = UIScreen.main.bounds
            return bounds.size
        }
        
        // Returns the screen size in pixels
        internal static func nativeScreenSizeForCurrentDevice() ->  CGSize {
            let bounds = UIScreen.main.nativeBounds
            return bounds.size
        }
    }
#endif
