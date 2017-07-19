import UIKit
import PiwikTracker

class MenuViewController: UITableViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PiwikTracker.shared?.track(view: ["menu"])
    }
}
