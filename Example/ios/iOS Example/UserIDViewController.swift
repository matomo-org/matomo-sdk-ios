import UIKit
import MatomoTracker

class UserIDViewController: UIViewController {
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    
    @IBAction func signinAction(_ sender: UIButton) {
        if (self.userIDTextField.text != nil) && (self.userIDTextField.text?.count)! > 0 {
            MatomoTracker.shared.userId = self.userIDTextField.text
            toggleState()
        }
    }
    
    @IBAction func signOutAction(_ sender: UIButton) {
        MatomoTracker.shared.userId = nil
        toggleState()
    }
    
    override func viewDidLoad() {
        toggleState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared.track(view: ["menu","user id"])
    }
    
    private func toggleState() {
        self.userIDTextField.text = MatomoTracker.shared.userId
        
        self.signinButton.isEnabled = !isVisitorIdValid()
        self.signoutButton.isEnabled = !self.signinButton.isEnabled
    }
    
    private func isVisitorIdValid() -> Bool {
        let currentVisitorId = MatomoTracker.shared.userId

        return (currentVisitorId != nil) && (currentVisitorId?.count)! > 0
    }
}
