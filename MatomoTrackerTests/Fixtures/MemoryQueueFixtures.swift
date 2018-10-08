@testable import MatomoTracker

struct EventFixture {
    static func event() -> Event {
        let visitor = Visitor(id: "spec_visitor_id", forcedId: nil, userId: "spec_user_id")
        let session = Session(sessionsCount: 0, lastVisit: Date(), firstVisit: Date())
        return Event(siteId: "spec_1", uuid: NSUUID.init(), visitor: visitor, session: session, date: Date(), url: URL(string: "http://spec_url")!, actionName: ["spec_action"], language: "spec_language", isNewSession: true, referer: nil,
                     customVariables: [],
                     eventCategory: nil,
                     eventAction: nil,
                     eventName: nil,
                     eventValue: nil,
                     campaignName: nil,
                     campaignKeyword: nil,
                     searchQuery: nil,
                     searchCategory: nil,
                     searchResultsCount: nil,
                     dimensions: [],
                     customTrackingParameters: [:],
                     contentName: nil,
                     contentPiece: nil,
                     contentTarget: nil,
                     contentInteraction: nil,
                     goalId: nil,
                     revenue: nil,
                     orderId: nil,
                     orderItems: [],
                     orderRevenue: nil,
                     orderSubTotal: nil,
                     orderTax: nil,
                     orderShippingCost: nil,
                     orderDiscount: nil,
                     orderLastDate: nil)
    }
}

struct MemoryQueueFixture {
    static func empty() -> MemoryQueue {
        return MemoryQueue()
    }
    static func withTwoItems() -> MemoryQueue {
        var queue = MemoryQueue()
        queue.enqueue(event: EventFixture.event())
        queue.enqueue(event: EventFixture.event())
        return queue
    }
}
