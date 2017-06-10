import UIKit
import PiwikTracker

class OptOutViewController: UIViewController {
    
    @IBOutlet weak var optOutSwitch: UISwitch!
    @IBAction func optOutSwitchChanged(_ sender: Any) {
        Tracker.shared?.isOptedOut = optOutSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optOutSwitch.isOn = Tracker.shared?.isOptedOut ?? false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tracker.shared?.track(view: ["menu","opt out"])
    }
}
