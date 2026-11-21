// swift-tools-version:6.0
//
// MatomoTracker
//

import PackageDescription

let package = Package(
  name: "MatomoTracker",
  platforms: [
      .iOS(.v15),
      .tvOS(.v15),
      .macOS(.v12),
      .visionOS(.v1),
      .watchOS(.v9),
  ],
  products: [
      .library(name: "MatomoTracker", targets: ["MatomoTracker"])
  ],
  targets: [
      .target(
          name: "MatomoTracker",
          path: "MatomoTracker",
          resources: [.copy("PrivacyInfo.xcprivacy")]
      ),
      .testTarget(
          name: "MatomoTrackerTests",
          dependencies: ["MatomoTracker"],
          path: "MatomoTrackerTests"
      ),
  ],
  swiftLanguageModes: [.v5]
)
