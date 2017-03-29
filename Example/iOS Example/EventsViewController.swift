import UIKit
import PiwikTracker

class EventsViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tracker.shared?.track(view: ["menu","events"])
    }
    @IBAction func trackEventButtonTapped(_ sender: UIButton) {
        Tracker.shared?.track(eventWithCategory: "TestCategory", action: "TestAction", name: "TestName", value: 7)
    }
}
