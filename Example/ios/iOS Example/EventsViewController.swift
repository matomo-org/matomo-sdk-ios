import UIKit
import MatomoTracker

class EventsViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared?.track(view: ["menu","events"])
    }
    @IBAction func trackEventButtonTapped(_ sender: UIButton) {
        MatomoTracker.shared?.track(eventWithCategory: "TestCategory", action: "TestAction", name: "TestName", value: 7)
    }
}
