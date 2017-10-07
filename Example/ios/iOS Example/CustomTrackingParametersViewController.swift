import UIKit
import PiwikTracker

class CustomTrackingParametersViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PiwikTracker.shared?.track(view: ["menu","custom tracking parameters"])
    }
    
    @IBAction func didTapSendDownloadEvent(_ sender: UIButton) {
        guard let piwikTracker = PiwikTracker.shared else { return }
        let downloadURL = URL(string: "https://builds.piwik.org/piwik.zip")!
        let event = Event(tracker: piwikTracker, action: ["menu", "custom tracking parameters"], url: downloadURL, customTrackingParameters: ["download": downloadURL.absoluteString])
        PiwikTracker.shared?.track(event)
    }

}

