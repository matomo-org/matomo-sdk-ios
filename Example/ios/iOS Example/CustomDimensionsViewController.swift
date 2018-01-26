import UIKit
import MatomoTracker

class CustomDimensionsViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared?.track(view: ["menu","custom dimensions"])
    }
    
    // Adds Custom Dimensions to every Event for OS version, Hardware and App version.
    @IBAction func setVisitCustomDimensionsTapped(_ sender: UIButton) {
        let application = Application.makeCurrentApplication()
        let device = Device.makeCurrentDevice()
        MatomoTracker.shared?.set(value: device.osVersion, forIndex: 1)
        MatomoTracker.shared?.set(value: device.humanReadablePlatformName ?? device.platform, forIndex: 2)
        MatomoTracker.shared?.set(value: application.bundleShortVersion ?? "unknown", forIndex: 3)
    }
}
