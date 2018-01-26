import UIKit
import MatomoTracker

class SecondScreenViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared?.track(view: ["menu","screen view", "screen view 2"])
    }
}
