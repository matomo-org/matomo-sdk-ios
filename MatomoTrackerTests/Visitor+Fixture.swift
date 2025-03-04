@testable import MatomoTracker

extension Visitor {
    static func fixture(id: String = "spec_visitor_id", forcedID: String? = nil, userID: String? = nil) -> Visitor {
        Visitor(id: id, forcedID: forcedID, userID: userID)
    }
}
