import UIKit
import MatomoTracker

class ScreenViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared?.track(view: ["menu","screen view"])
    }
}
