import UIKit
import MatomoTracker

class UserIDViewController: UIViewController {
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    
    @IBAction func signinAction(_ sender: UIButton) {
        if (self.userIDTextField.text != nil) && (self.userIDTextField.text?.characters.count)! > 0 {
            MatomoTracker.shared?.visitorId = self.userIDTextField.text
            toggleState()
        }
    }
    
    @IBAction func signOutAction(_ sender: UIButton) {
        MatomoTracker.shared?.visitorId = nil
        toggleState()
    }
    
    override func viewDidLoad() {
        toggleState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared?.track(view: ["menu","user id"])
    }
    
    private func toggleState() {
        self.userIDTextField.text = MatomoTracker.shared?.visitorId
        
        self.signinButton.isEnabled = !isVisitorIdValid()
        self.signoutButton.isEnabled = !self.signinButton.isEnabled
    }
    
    private func isVisitorIdValid() -> Bool {
        let currentVisitorId = MatomoTracker.shared?.visitorId

        return (currentVisitorId != nil) && (currentVisitorId?.characters.count)! > 0
    }
}
