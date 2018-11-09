import UIKit
import MatomoTracker

class ConfigurationViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared.track(view: ["menu","configuration"])
    }
    
    @IBAction func newSessionButtonTapped(_ sender: UIButton) {
        MatomoTracker.shared.startNewSession()
    }
    
    @IBAction func dispatchButtonTapped(_ sender: UIButton) {
        MatomoTracker.shared.dispatch()
    }

}
