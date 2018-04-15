import UIKit
import MatomoTracker

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MatomoTracker.shared.track(view: ["menu","search"])
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        MatomoTracker.shared.trackSearch(query: query, category: "MatomoTracker Search", resultCount: Int(arc4random_uniform(100)))
    }
}

