import UIKit
import MatomoTracker

class ConfigurationViewController: UIViewController {
    
    @IBOutlet weak var baseURLTextField: UITextField!
    @IBOutlet weak var siteIDTextField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared?.track(view: ["menu","configuration"])
        
        baseURLTextField.text = UserDefaults.standard.url(forKey: "matomo-example-baseurl")?.absoluteString
        siteIDTextField.text = UserDefaults.standard.string(forKey: "matomo-example-siteid")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let baseURLText = baseURLTextField.text,
            let baseURL = URL(string: baseURLText),
            let siteID = siteIDTextField.text else { return }
        UserDefaults.standard.set(baseURL, forKey: "matomo-example-baseurl")
        UserDefaults.standard.set(siteID, forKey: "matomo-example-siteid")
        UserDefaults.standard.synchronize()
        
        MatomoTracker.configureSharedInstance(withSiteID: siteID, baseURL: baseURL)
    }
    
    @IBAction func newSessionButtonTapped(_ sender: UIButton) {
        MatomoTracker.shared?.startNewSession()
    }
    
    @IBAction func dispatchButtonTapped(_ sender: UIButton) {
        MatomoTracker.shared?.dispatch()
    }

}
