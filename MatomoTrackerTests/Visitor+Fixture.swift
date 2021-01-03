@testable import MatomoTracker

extension Visitor {
    static func fixture(id: String = "spec_visitor_id", forcedId: String? = nil, userId: String? = nil) -> Visitor {
        Visitor(id: id, forcedId: forcedId, userId: userId)
    }
}
