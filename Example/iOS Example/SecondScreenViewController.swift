import UIKit
import PiwikTracker

class SecondScreenViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PiwikTracker.shared?.track(view: ["menu","screen view", "screen view 2"])
    }
}
