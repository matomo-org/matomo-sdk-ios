import UIKit
import MatomoTracker

class OptOutViewController: UIViewController {
    
    @IBOutlet weak var optOutSwitch: UISwitch!
    @IBAction func optOutSwitchChanged(_ sender: Any) {
        MatomoTracker.shared.isOptedOut = optOutSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optOutSwitch.isOn = MatomoTracker.shared.isOptedOut
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared.track(view: ["menu","opt out"])
    }
}
