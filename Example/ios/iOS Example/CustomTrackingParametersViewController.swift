import UIKit
import MatomoTracker

class CustomTrackingParametersViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared?.track(view: ["menu","custom tracking parameters"])
    }
    
    @IBAction func didTapSendDownloadEvent(_ sender: UIButton) {
        guard let matomoTracker = MatomoTracker.shared else { return }
        let downloadURL = URL(string: "https://builds.matomo.org/matomo.zip")!
        let event = Event(tracker: matomoTracker, action: ["menu", "custom tracking parameters"], url: downloadURL, customTrackingParameters: ["download": downloadURL.absoluteString])
        MatomoTracker.shared?.track(event)
    }

}

