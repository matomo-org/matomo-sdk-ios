import UIKit
import PiwikTracker

class CustomDimensionsViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PiwikTracker.shared?.track(view: ["menu","custom dimensions"])
    }
    
    // Adds Custom Dimensions to every Event for OS version, Hardware and App version.
    @IBAction func setVisitCustomDimensionsTapped(_ sender: UIButton) {
        let application = Application.makeCurrentApplication()
        let device = Device.makeCurrentDevice()
        PiwikTracker.shared?.set(value: device.osVersion, forIndex: 1)
        PiwikTracker.shared?.set(value: device.humanReadablePlatformName ?? device.platform, forIndex: 2)
        PiwikTracker.shared?.set(value: application.bundleShortVersion ?? "unknown", forIndex: 3)
    }
}
