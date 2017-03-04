import UIKit
import PiwikTracker

class MenuViewController: UITableViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tracker.sharedInstance?.track(view: ["menu"])
    }
}
