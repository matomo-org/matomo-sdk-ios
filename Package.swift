// swift-tools-version:5.0
//
// MatomoTracker
//

import PackageDescription

let package = Package(
  name: "MatomoTracker",
  products: [
      .library(name: "MatomoTracker", targets: ["MatomoTracker"])
  ],
  targets: [
      .target(name: "MatomoTracker", dependencies: [], path: "MatomoTracker"),
  ],
  swiftLanguageVersions: [.v5]
)
