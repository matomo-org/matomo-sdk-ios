@testable import PiwikTracker

struct EventFixture {
    static func event() -> Event {
        let visitor = Visitor(id: "spec_visitor_id", userId: "spec_user_id")
        let session = Session(sessionsCount: 0, lastVisit: Date(), firstVisit: Date())
        return Event(uuid: NSUUID.init(), visitor: visitor, session: session, date: Date(), url: URL(string: "http://spec_url")!, actionName: ["spec_action"], language: "spec_language", isNewSession: true, referer: nil)
    }
}

struct MemoryQueueFixture {
    static func empty() -> MemoryQueue {
        return MemoryQueue()
    }
    static func withTwoItems() -> MemoryQueue {
        var queue = MemoryQueue()
        queue.queue(item: EventFixture.event(), completion: {})
        queue.queue(item: EventFixture.event(), completion: {})
        return queue
    }
}
