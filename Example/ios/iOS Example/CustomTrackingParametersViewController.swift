import UIKit
import MatomoTracker

class CustomTrackingParametersViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared.track(view: ["menu","custom tracking parameters"])
    }
    
    @IBAction func didTapSendDownloadEvent(_ sender: UIButton) {
        let downloadURL = URL(string: "https://builds.piwik.org/piwik.zip")!
        let event = Event(tracker: MatomoTracker.shared, action: ["menu", "custom tracking parameters"], url: downloadURL, customTrackingParameters: ["download": downloadURL.absoluteString], isCustomAction: false)
        MatomoTracker.shared.track(event)
    }

}

