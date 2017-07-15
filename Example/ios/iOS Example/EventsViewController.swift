import UIKit
import PiwikTracker

class EventsViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PiwikTracker.shared?.track(view: ["menu","events"])
    }
    @IBAction func trackEventButtonTapped(_ sender: UIButton) {
        PiwikTracker.shared?.track(eventWithCategory: "TestCategory", action: "TestAction", name: "TestName", value: 7)
    }
}
