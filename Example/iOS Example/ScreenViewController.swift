import UIKit
import PiwikTracker

class ScreenViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PiwikTracker.shared?.track(view: ["menu","screen view"])
    }
}
