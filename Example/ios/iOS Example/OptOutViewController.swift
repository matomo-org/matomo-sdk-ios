import UIKit
import PiwikTracker

class OptOutViewController: UIViewController {
    
    @IBOutlet weak var optOutSwitch: UISwitch!
    @IBAction func optOutSwitchChanged(_ sender: Any) {
        PiwikTracker.shared?.isOptedOut = optOutSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optOutSwitch.isOn = PiwikTracker.shared?.isOptedOut ?? false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PiwikTracker.shared?.track(view: ["menu","opt out"])
    }
}
