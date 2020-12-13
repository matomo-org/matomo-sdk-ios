import UIKit
import MatomoTracker

class MenuViewController: UITableViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared.track(eventWithCategory: "timing", action: "one")
        MatomoTracker.shared.track(view: ["menu"])
        MatomoTracker.shared.track(eventWithCategory: "timing", action: "two")
    }
}
