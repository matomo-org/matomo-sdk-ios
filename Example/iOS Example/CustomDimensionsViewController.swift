import UIKit
import PiwikTracker

class CustomDimensionsViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tracker.shared?.track(view: ["menu","custom dimensions"])
    }
    
    // Adds Custom Dimensions to every Event for OS version, Hardware and App version.
    @IBAction func setVisitCustomDimensionsTapped(_ sender: UIButton) {
        let application = Application.makeCurrentApplication()
        let device = Device.makeCurrentDevice()
        Tracker.shared?.set(value: device.osVersion, forIndex: 1)
        Tracker.shared?.set(value: device.humanReadablePlatformName ?? device.platform, forIndex: 2)
        Tracker.shared?.set(value: application.bundleShortVersion ?? "unknown", forIndex: 3)
    }
}
