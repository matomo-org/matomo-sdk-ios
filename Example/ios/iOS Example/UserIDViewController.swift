import UIKit
import PiwikTracker

class UserIDViewController: UIViewController {
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    
    @IBAction func signinAction(_ sender: UIButton) {
        if (self.userIDTextField.text != nil) && (self.userIDTextField.text?.characters.count)! > 0 {
            PiwikTracker.shared?.visitorId = self.userIDTextField.text
            toggleState()
        }
    }
    
    @IBAction func signOutAction(_ sender: UIButton) {
        PiwikTracker.shared?.visitorId = nil
        toggleState()
    }
    
    override func viewDidLoad() {
        toggleState()
    }
    
    private func toggleState() {
        self.userIDTextField.text = PiwikTracker.shared?.visitorId
        
        self.signinButton.isEnabled = !isVisitorIdValid()
        self.signoutButton.isEnabled = !self.signinButton.isEnabled
    }
    
    private func isVisitorIdValid() -> Bool {
        let currentVisitorId = PiwikTracker.shared?.visitorId

        return (currentVisitorId != nil) && (currentVisitorId?.characters.count)! > 0
    }
}
