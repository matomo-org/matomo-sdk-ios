import Foundation

/// The Matomo Tracker is a Swift framework to send analytics to the Matomo server.
///
/// ## Basic Usage
/// * Use the track methods to track your views, events and more.
///
/// ## Threading
/// All methods and properties can be used from any thread. The tracker never blocks on the main thread.
/// Tracking methods capture the current state (visitor, session, dimensions, …) when they are called and
/// queue the event in the background, in the order of the calls.
final public class MatomoTracker: NSObject {

    // MARK: State

    /// The mutable state of the tracker. Only accessed while holding `stateLock`, using `withState`.
    private struct State {
        var matomoUserDefaults: MatomoUserDefaults
        var visitor: Visitor
        var session: Session
        var nextEventStartsANewSession = true
        var dimensions: [CustomDimension] = []
        var customVariables: [CustomVariable] = []
        var campaignName: String? = nil
        var campaignKeyword: String? = nil
        var contentBase: URL?
        var logger: Logger = DefaultLogger(minLevel: .warning)
        var dispatchInterval: TimeInterval = 30.0
    }

    private let stateLock = NSLock()
    private var state: State

    /// Runs `body` while holding the state lock.
    ///
    /// Never call out to the logger, the queue, the dispatcher or any other code that might call back
    /// into the tracker from within `body`, since the lock isn't reentrant.
    private func withState<T>(_ body: (inout State) throws -> T) rethrows -> T {
        stateLock.lock()
        defer { stateLock.unlock() }
        return try body(&state)
    }

    // MARK: Work queue

    /// The serial queue that owns the `queue`, the `dispatcher` and the dispatch timer.
    private let workQueue = DispatchQueue(label: "org.matomo.tracker")
    private let workQueueKey = DispatchSpecificKey<Void>()

    /// Only accessed on the `workQueue`.
    private var queue: Queue
    /// Only accessed on the `workQueue`.
    private let dispatcher: Dispatcher

    /// Defines if the user opted out of tracking. When set to true, every event
    /// will be discarded immediately. This property is persisted between app launches.
    @objc public var isOptedOut: Bool {
        get {
            withState { $0.matomoUserDefaults.optOut }
        }
        set {
            withState { $0.matomoUserDefaults.optOut = newValue }
        }
    }

    /// Will be used to associate all future events with a given userID. This property
    /// is persisted between app launches.
    @available(*, deprecated, renamed: "userID")
    @objc public var userId: String? {
        get {
            userID
        }
        set {
            userID = newValue
        }
    }

    /// Will be used to associate all future events with a given userID. This property
    /// is persisted between app launches.
    @objc public var userID: String? {
        get {
            withState { $0.matomoUserDefaults.visitorUserID }
        }
        set {
            withState { state in
                state.matomoUserDefaults.visitorUserID = newValue
                state.visitor = Visitor.current(in: state.matomoUserDefaults)
            }
        }
    }

    /// Readonly property of the visitor ID.
    @available(*, deprecated, renamed: "visitorID")
    @objc public var visitorId: String? {
        visitorID
    }

    /// Readonly property of the visitor ID.
    @objc public var visitorID: String? {
        visitor.id
    }

    /// Will be used to associate all future events with a given visitorId / cid. This property
    /// is persisted between app launches.
    /// The `forcedVisitorId` can only be a 16 character long hexadecimal string. Setting an invalid
    /// string will have no effect.
    @available(*, deprecated, renamed: "forcedVisitorID")
    @objc public var forcedVisitorId: String? {
        get {
            forcedVisitorID
        }
        set {
            forcedVisitorID = newValue
        }
    }

    /// Will be used to associate all future events with a given visitorId / cid. This property
    /// is persisted between app launches.
    /// The `forcedVisitorID` can only be a 16 character long hexadecimal string. Setting an invalid
    /// string will have no effect.
    @objc public var forcedVisitorID: String? {
        get {
            withState { $0.matomoUserDefaults.forcedVisitorID }
        }
        set {
            logger.debug("Setting the forcedVisitorID to \(newValue ?? "nil")")
            if let newValue = newValue {
                let isValidString = UInt64(newValue, radix: 16) != nil && newValue.count == 16
                guard isValidString else {
                    logger.error("forcedVisitorID is invalid. It must be a 16 character long hex string.")
                    logger.error("forcedVisitorID is still \(forcedVisitorID ?? "nil")")
                    return
                }
            }
            withState { state in
                state.matomoUserDefaults.forcedVisitorID = newValue
                state.visitor = Visitor.current(in: state.matomoUserDefaults)
            }
        }
    }

    internal let siteID: String

    internal var visitor: Visitor { withState { $0.visitor } }
    internal var session: Session { withState { $0.session } }
    internal var nextEventStartsANewSession: Bool { withState { $0.nextEventStartsANewSession } }
    internal var dimensions: [CustomDimension] { withState { $0.dimensions } }
    internal var customVariables: [CustomVariable] { withState { $0.customVariables } }
    internal var campaignName: String? { withState { $0.campaignName } }
    internal var campaignKeyword: String? { withState { $0.campaignKeyword } }

    /// This logger is used to perform logging of all sorts of Matomo related information.
    /// Per default it is a `DefaultLogger` with a `minLevel` of `LogLevel.warning`. You can
    /// set your own Logger with a custom `minLevel` or a complete custom logging mechanism.
    ///
    /// The logger can be called from any thread.
    @objc public var logger: Logger {
        get {
            withState { $0.logger }
        }
        set {
            withState { $0.logger = newValue }
        }
    }

    /// The `contentBase` is used to build the url of an Event, if the Event hasn't got a url set.
    /// This autogenerated url will then have the format <contentBase>/<actions>.
    /// Per default the `contentBase` is http://<Application Bundle Name>.
    /// Set the `contentBase` to nil, if you don't want to auto generate a url.
    @objc public var contentBase: URL? {
        get {
            withState { $0.contentBase }
        }
        set {
            withState { $0.contentBase = newValue }
        }
    }

    internal static var _sharedInstance: MatomoTracker?

    /// Create and Configure a new Tracker
    ///
    /// - Parameters:
    ///   - siteId: The unique site id generated by the server when a new site was created.
    ///   - queue: The queue to use to store all analytics until it is dispatched to the server.
    ///   - dispatcher: The dispatcher to use to transmit all analytics to the server.
    @available(*, deprecated, renamed: "init(siteID:queue:dispatcher:)")
    public convenience init(siteId: String, queue: Queue, dispatcher: Dispatcher) {
        self.init(siteID: siteId, queue: queue, dispatcher: dispatcher)
    }

    /// Create and Configure a new Tracker
    ///
    /// The tracker calls the `queue` and the `dispatcher` on an internal serial queue, never
    /// concurrently and not on the main thread.
    ///
    /// - Parameters:
    ///   - siteID: The unique site id generated by the server when a new site was created.
    ///   - queue: The queue to use to store all analytics until it is dispatched to the server.
    ///   - dispatcher: The dispatcher to use to transmit all analytics to the server.
    required public init(siteID: String, queue: Queue, dispatcher: Dispatcher) {
        self.siteID = siteID
        self.queue = queue
        self.dispatcher = dispatcher
        let matomoUserDefaults = MatomoUserDefaults(suiteName: "\(siteID)\(dispatcher.baseURL.absoluteString)")
        self.state = State(
            matomoUserDefaults: matomoUserDefaults,
            visitor: Visitor.current(in: matomoUserDefaults),
            session: Session.current(in: matomoUserDefaults),
            contentBase: URL(string: "http://\(Application.makeCurrentApplication().bundleIdentifier ?? "unknown")")
        )
        super.init()
        workQueue.setSpecific(key: workQueueKey, value: ())
        startNewSession()
        workQueue.async { [weak self] in
            self?.scheduleDispatchTimer()
        }
    }

    /// Create and Configure a new Tracker
    ///
    /// A volatile memory queue will be used to store the analytics data. All not transmitted data will be lost when the application gets terminated.
    /// The URLSessionDispatcher will be used to transmit the data to the server.
    ///
    /// - Parameters:
    ///   - siteId: The unique site id generated by the server when a new site was created.
    ///   - baseURL: The url of the Matomo server. This url has to end in `piwik.php` or `matomo.php`.
    ///   - userAgent: An optional parameter for custom user agent.
    @available(*, deprecated, renamed: "init(siteID:baseURL:userAgent:)")
    @objc convenience public init(siteId: String, baseURL: URL, userAgent: String? = nil) {
        self.init(siteID: siteId, baseURL: baseURL, userAgent: userAgent)
    }

    /// Create and Configure a new Tracker
    ///
    /// A volatile memory queue will be used to store the analytics data. All not transmitted data will be lost when the application gets terminated.
    /// The URLSessionDispatcher will be used to transmit the data to the server.
    ///
    /// - Parameters:
    ///   - siteID: The unique site id generated by the server when a new site was created.
    ///   - baseURL: The url of the Matomo server. This url has to end in `piwik.php` or `matomo.php`.
    ///   - userAgent: An optional parameter for custom user agent.
    @objc convenience public init(siteID: String, baseURL: URL, userAgent: String? = nil) {
        let validSuffix = baseURL.absoluteString.hasSuffix("piwik.php") ||
            baseURL.absoluteString.hasSuffix("matomo.php")
        assert(validSuffix, "The baseURL is expected to end in piwik.php or matomo.php")

        let queue = MemoryQueue()
        let dispatcher = URLSessionDispatcher(baseURL: baseURL, userAgent: userAgent)
        self.init(siteID: siteID, queue: queue, dispatcher: dispatcher)
    }

    deinit {
        dispatchTimer?.cancel()
    }

    // MARK: Event context

    /// The state an `Event` captures when it is created.
    internal struct EventContext {
        let siteID: String
        let visitor: Visitor
        let session: Session
        let isNewSession: Bool
        let contentBase: URL?
        let dimensions: [CustomDimension]
        let customVariables: [CustomVariable]
        let campaignName: String?
        let campaignKeyword: String?
    }

    /// A consistent snapshot of the state that is captured in an `Event`.
    internal func eventContext() -> EventContext {
        withState { state in
            EventContext(
                siteID: siteID,
                visitor: state.visitor,
                session: state.session,
                isNewSession: state.nextEventStartsANewSession,
                contentBase: state.contentBase,
                dimensions: state.dimensions,
                customVariables: state.customVariables,
                campaignName: state.campaignName,
                campaignKeyword: state.campaignKeyword
            )
        }
    }

    // MARK: Queueing

    internal func queue(event: Event) {
        enqueue(event, consumesCampaign: false)
    }

    private func enqueue(_ event: Event, consumesCampaign: Bool) {
        var event = event
        let isQueued: Bool = withState { state in
            guard !state.matomoUserDefaults.optOut else { return false }
            if event.isNewSession {
                if state.nextEventStartsANewSession {
                    state.nextEventStartsANewSession = false
                } else {
                    // Another event already started the new session.
                    event.isNewSession = false
                }
            }
            if consumesCampaign && event.campaignName == state.campaignName && event.campaignKeyword == state.campaignKeyword {
                state.campaignName = nil
                state.campaignKeyword = nil
            }
            // Scheduled while holding the lock, so events are queued in the order they pass the lock.
            // The block retains the tracker, so the event is queued even if the tracker is released right away.
            workQueue.async {
                self.queue.enqueue(event: event)
            }
            return true
        }
        if isQueued {
            logger.verbose("Queued event: \(event)")
        }
    }

    // MARK: Dispatching

    private let numberOfEventsDispatchedAtOnce = 20
    /// Only accessed on the `workQueue`.
    private(set) var isDispatching = false
    /// Only accessed on the `workQueue`.
    private var dispatchCompletions: [() -> Void] = []

    /// Manually start the dispatching process. You might want to call this method in AppDelegates `applicationDidEnterBackground` to transmit all data
    /// whenever the user leaves the application.
    @objc public func dispatch() {
        dispatch(completion: nil)
    }

    /// Manually start the dispatching process and get notified when it has finished.
    ///
    /// You might want to call this method in AppDelegates `applicationDidEnterBackground` to transmit all data
    /// whenever the user leaves the application, and end your background task in the `completion`.
    ///
    /// - Parameter completion: Called when dispatching has finished, either because all events were sent or because sending failed.
    ///   If the tracker is already dispatching, it is called when that dispatch has finished. It is called on an internal queue.
    @objc public func dispatch(completion: (() -> Void)?) {
        workQueue.async { [weak self] in
            self?.startDispatching(completion: completion)
        }
    }

    /// Must be called on the `workQueue`.
    private func startDispatching(completion: (() -> Void)?) {
        if let completion = completion {
            dispatchCompletions.append(completion)
        }
        guard !isDispatching else {
            logger.verbose("MatomoTracker is already dispatching.")
            return
        }
        guard queue.eventCount > 0 else {
            logger.info("No need to dispatch. Dispatch queue is empty.")
            finishDispatching()
            return
        }
        logger.info("Start dispatching events")
        isDispatching = true
        dispatchTimer?.cancel()
        dispatchTimer = nil
        dispatchBatch()
    }

    /// Must be called on the `workQueue`.
    private func dispatchBatch() {
        let workQueue = self.workQueue
        queue.first(limit: numberOfEventsDispatchedAtOnce) { [weak self] events in
            workQueue.async {
                self?.send(events)
            }
        }
    }

    /// Must be called on the `workQueue`.
    private func send(_ events: [Event]) {
        guard events.count > 0 else {
            // there are no more events queued, finish dispatching
            logger.info("Finished dispatching events")
            finishDispatching()
            return
        }
        let workQueue = self.workQueue
        dispatcher.send(events: events, success: { [weak self] in
            workQueue.async {
                self?.remove(events)
            }
        }, failure: { [weak self] error in
            workQueue.async {
                guard let self = self else { return }
                self.logger.warning("Failed dispatching events with error \(error)")
                self.finishDispatching()
            }
        })
    }

    /// Must be called on the `workQueue`.
    private func remove(_ events: [Event]) {
        let workQueue = self.workQueue
        queue.remove(events: events) { [weak self] in
            workQueue.async {
                guard let self = self else { return }
                self.logger.info("Dispatched batch of \(events.count) events.")
                self.dispatchBatch()
            }
        }
    }

    /// Must be called on the `workQueue`.
    private func finishDispatching() {
        isDispatching = false
        scheduleDispatchTimer()
        let completions = dispatchCompletions
        dispatchCompletions = []
        completions.forEach { $0() }
    }

    // MARK: Dispatch timer

    @objc public var dispatchInterval: TimeInterval {
        get {
            withState { $0.dispatchInterval }
        }
        set {
            withState { $0.dispatchInterval = newValue }
            workQueue.async { [weak self] in
                self?.scheduleDispatchTimer()
            }
        }
    }

    /// Only accessed on the `workQueue`.
    private var dispatchTimer: DispatchSourceTimer?

    /// Must be called on the `workQueue`.
    private func scheduleDispatchTimer() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        let dispatchInterval = self.dispatchInterval
        guard dispatchInterval > 0 else { return } // Discussion: Do we want the possibility to dispatch synchronous? That than would be dispatchInterval = 0
        let timer = DispatchSource.makeTimerSource(queue: workQueue)
        timer.schedule(deadline: .now() + dispatchInterval)
        timer.setEventHandler { [weak self] in
            self?.startDispatching(completion: nil)
        }
        timer.resume()
        dispatchTimer = timer
    }

    // MARK: Testing

    /// Waits until all work that was scheduled on the internal queue before this call has finished.
    ///
    /// Only meant for tests. Must not be called from the internal queue.
    internal func waitUntilIdle() {
        precondition(DispatchQueue.getSpecific(key: workQueueKey) == nil, "waitUntilIdle() must not be called from the tracker's internal queue")
        workQueue.sync {}
    }

    /// Adds the name and keyword for the current campaign.
    /// This is usually very helpfull if you use deeplinks into your app.
    ///
    /// More information on campaigns: [https://matomo.org/docs/tracking-campaigns/](https://matomo.org/docs/tracking-campaigns/)
    ///
    /// - Parameters:
    ///   - name: The name of the campaign.
    ///   - keyword: The keyword of the campaign.
    @objc public func trackCampaign(name: String?, keyword: String?) {
        withState { state in
            state.campaignName = name
            state.campaignKeyword = keyword
        }
    }

    /// There are several ways to track content impressions and interactions manually, semi-automatically and automatically. Please be aware that content impressions will be tracked using bulk tracking which will always send a POST request, even if  GET is configured which is the default. For more details have a look at the in-depth guide to Content Tracking.
    /// More information on content: [https://matomo.org/docs/content-tracking/](https://matomo.org/docs/content-tracking/)
    ///
    /// - Parameters:
    ///   - name: The name of the content. For instance 'Ad Foo Bar'
    ///   - piece: The actual content piece. For instance the path to an image, video, audio, any text
    ///   - target: The target of the content. For instance the URL of a landing page
    ///   - interaction: The name of the interaction with the content. For instance a 'click'
    @objc public func trackContentImpression(name: String, piece: String?, target: String?) {
        track(Event(tracker: self, action: [], contentName: name, contentPiece: piece, contentTarget: target, isCustomAction: false))
    }
    @objc public func trackContentInteraction(name: String, interaction: String, piece: String?, target: String?) {
        track(Event(tracker: self, action: [], contentName: name, contentInteraction: interaction, contentPiece: piece, contentTarget: target, isCustomAction: false))
    }
}

extension MatomoTracker {
    /// Starts a new Session
    ///
    /// Use this function to manually start a new Session. A new Session will be automatically created only on app start.
    /// You can use the AppDelegates `applicationWillEnterForeground` to start a new visit whenever the app enters foreground.
    @objc public func startNewSession() {
        withState { MatomoTracker.startNewSession(in: &$0) }
    }

    private static func startNewSession(in state: inout State) {
        state.matomoUserDefaults.previousVisit = state.matomoUserDefaults.currentVisit
        state.matomoUserDefaults.currentVisit = Date()
        state.matomoUserDefaults.totalNumberOfVisits += 1
        state.nextEventStartsANewSession = true
        state.session = Session.current(in: state.matomoUserDefaults)
    }
}

extension MatomoTracker {

    /// Tracks a custom Event
    ///
    /// - Parameter event: The event that should be tracked.
    public func track(_ event: Event) {
        enqueue(event, consumesCampaign: true)
    }

    /// Tracks a screenview.
    ///
    /// This method can be used to track hierarchical screen names, e.g. screen/settings/register. Use this to create a hierarchical and logical grouping of screen views in the Matomo web interface.
    ///
    /// - Parameter view: An array of hierarchical screen names.
    /// - Parameter url: The optional url of the page that was viewed.
    /// - Parameter dimensions: An optional array of dimensions, that will be set only in the scope of this view.
    public func track(view: [String], url: URL? = nil, dimensions: [CustomDimension] = []) {
        let event = Event(tracker: self, action: view, url: url, dimensions: dimensions, isCustomAction: false)
        queue(event: event)
    }

    /// Tracks an event as described here: https://matomo.org/docs/event-tracking/
    ///
    /// - Parameters:
    ///   - category: The Category of the Event
    ///   - action: The Action of the Event
    ///   - name: The optional name of the Event
    ///   - value: The optional value of the Event
    ///   - dimensions: An optional array of dimensions, that will be set only in the scope of this event.
    ///   - url: The optional url of the page that was viewed.
    public func track(eventWithCategory category: String, action: String, name: String? = nil, value: Float? = nil, dimensions: [CustomDimension] = [], url: URL? = nil) {
        let event = Event(tracker: self, action: [], url: url, eventCategory: category, eventAction: action, eventName: name, eventValue: value, dimensions: dimensions, isCustomAction: true)
        queue(event: event)
    }

    /// Tracks a goal as described here: https://matomo.org/docs/tracking-goals-web-analytics/
    ///
    /// - Parameters:
    ///   - goalId: The defined ID of the Goal
    ///   - revenue: The monetary value that was generated by the Goal
    public func trackGoal(id goalID: Int?, revenue: Float?) {
        let event = Event(tracker: self, action: [], goalID: goalID, revenue: revenue, isCustomAction: false)
        queue(event: event)
    }

    /// Tracks an order as described here: https://matomo.org/faq/reports/advanced-manually-tracking-ecommerce-actions-in-matomo/#tracking-orders-to-matomo-required
    ///
    /// - Parameters:
    ///   - id: The unique ID of the order
    ///   - items: The array of items to be ordered
    ///   - revenue: The grand total for the order (includes tax, shipping and subtracted discount)
    ///   - subTotal: The sub total of the order (excludes shipping)
    ///   - tax: The tax amount of the order
    ///   - shippingCost: The shipping cost of the order
    ///   - discount: The discount offered
    public func trackOrder(id: String, items: [OrderItem], revenue: Float, subTotal: Float? = nil, tax: Float? = nil, shippingCost: Float? = nil, discount: Float? = nil) {
        let lastOrderDate: Date? = withState { state in
            let lastOrderDate = state.matomoUserDefaults.lastOrder
            state.matomoUserDefaults.lastOrder = Date()
            return lastOrderDate
        }

        let event = Event(tracker: self, action: [], orderID: id, orderItems: items, orderRevenue: revenue, orderSubTotal: subTotal, orderTax: tax, orderShippingCost: shippingCost, orderDiscount: discount, orderLastDate: lastOrderDate, isCustomAction: false)
        queue(event: event)
    }
}

extension MatomoTracker {

    /// Tracks a search result page as described here: https://matomo.org/docs/site-search/
    ///
    /// - Parameters:
    ///   - query: The string the user was searching for
    ///   - category: An optional category which the user was searching in
    ///   - resultCount: The number of results that were displayed for that search
    ///   - dimensions: An optional array of dimensions, that will be set only in the scope of this event.
    ///   - url: The optional url of the page that was viewed.
    public func trackSearch(query: String, category: String?, resultCount: Int?, dimensions: [CustomDimension] = [], url: URL? = nil) {
        let event = Event(tracker: self, action: [], url: url, searchQuery: query, searchCategory: category, searchResultsCount: resultCount, dimensions: dimensions, isCustomAction: false)
        queue(event: event)
    }
}

extension MatomoTracker {
    /// Set a permanent custom dimension.
    ///
    /// Use this method to set a dimension that will be send with every event. This is best for Custom Dimensions in scope "Visit". A typical example could be any device information or the version of the app the visitor is using.
    ///
    /// For more information on custom dimensions visit https://matomo.org/docs/custom-dimensions/
    ///
    /// - Parameter value: The value you want to set for this dimension.
    /// - Parameter index: The index of the dimension. A dimension with this index must be setup in the Matomo backend.
    @available(*, deprecated, message: "use setDimension: instead")
    public func set(value: String, forIndex index: Int) {
        set(dimension: CustomDimension(index: index, value: value))
    }

    /// Set a permanent custom dimension.
    ///
    /// Use this method to set a dimension that will be send with every event. This is best for Custom Dimensions in scope "Visit". A typical example could be any device information or the version of the app the visitor is using.
    ///
    /// For more information on custom dimensions visit https://matomo.org/docs/custom-dimensions/
    ///
    /// - Parameter dimension: The Dimension to set
    public func set(dimension: CustomDimension) {
        withState { state in
            state.dimensions.removeAll { $0.index == dimension.index }
            state.dimensions.append(dimension)
        }
    }

    /// Set a permanent custom dimension by value and index.
    ///
    /// This is a convenience alternative to set(dimension:) and calls the exact same functionality. Also, it is accessible from Objective-C.
    ///
    /// - Parameter value: The value for the new Custom Dimension
    /// - Parameter forIndex: The index of the new Custom Dimension
    @objc public func setDimension(_ value: String, forIndex index: Int) {
        set(dimension: CustomDimension( index: index, value: value ));
    }

    /// Removes a previously set custom dimension.
    ///
    /// Use this method to remove a dimension that was set using `set(dimension:)` or `setDimension(_:forIndex:)`.
    ///
    /// - Parameter index: The index of the dimension.
    @objc public func remove(dimensionAtIndex index: Int) {
        withState { state in
            state.dimensions.removeAll { $0.index == index }
        }
    }
}


extension MatomoTracker {

    /// Set a permanent new Custom Variable.
    ///
    /// - Parameter dimension: The Custom Variable to set
    public func set(customVariable: CustomVariable) {
        withState { state in
            state.customVariables.removeAll { $0.index == customVariable.index }
            state.customVariables.append(customVariable)
        }
    }

    /// Set a permanent new Custom Variable.
    ///
    /// - Parameter name: The index of the new Custom Variable
    /// - Parameter name: The name of the new Custom Variable
    /// - Parameter value: The value of the new Custom Variable
    @objc public func setCustomVariable(withIndex index: UInt, name: String, value: String) {
        set(customVariable: CustomVariable(index: index, name: name, value: value))
    }

    /// Remove a previously set Custom Variable.
    ///
    /// - Parameter index: The index of the Custom Variable.
    @objc public func removeCustomVariable(withIndex index: UInt) {
        withState { state in
            state.customVariables.removeAll { $0.index == index }
        }
    }
}

extension MatomoTracker {
    /// Tracks an outlink: an external URL the user has opened, for example in an in-app browser.
    ///
    /// The URL can have any scheme, like `https`, `mailto` or a custom app scheme. A URL without
    /// a scheme can't be an outlink and isn't tracked.
    ///
    /// More info: https://matomo.org/faq/new-to-matomo/faq_71/
    ///
    /// - Parameters:
    ///   - url: The external URL the user has opened.
    ///   - dimensions: An optional array of dimensions, that will be set only in the scope of this event.
    public func trackOutlink(_ url: URL, dimensions: [CustomDimension] = []) {
        guard url.absoluteURL.scheme != nil else {
            logger.warning("Not tracking the outlink \(url.absoluteString), because it has no scheme.")
            return
        }
        let event = Event(tracker: self, action: [], link: url, dimensions: dimensions, isCustomAction: false)
        queue(event: event)
    }
}

// Objective-c compatibility extension
extension MatomoTracker {
    @objc public func track(view: [String], url: URL? = nil) {
        track(view: view, url: url, dimensions: [])
    }

    @objc public func track(eventWithCategory category: String, action: String, name: String? = nil, number: NSNumber? = nil, url: URL? = nil) {
        let value = number == nil ? nil : number!.floatValue
        track(eventWithCategory: category, action: action, name: name, value: value, url: url)
    }

    @available(*, deprecated, message: "use track(eventWithCategory:action:name:number:url instead")
    @objc public func track(eventWithCategory category: String, action: String, name: String? = nil, number: NSNumber? = nil) {
        track(eventWithCategory: category, action: action, name: name, number: number, url: nil)
    }

    @objc public func trackSearch(query: String, category: String?, resultCount: Int, url: URL? = nil) {
        trackSearch(query: query, category: category, resultCount: resultCount, dimensions: [], url: url)
    }

    @objc public func trackOutlink(_ url: URL) {
        trackOutlink(url, dimensions: [])
    }
}

extension MatomoTracker {
    @objc public func copyFromOldSharedInstance() {
        withState { state in
            state.matomoUserDefaults.copy(from: UserDefaults.standard)
        }
    }
}

extension MatomoTracker {
    /// The version of the Matomo SDKs
    @objc public static let sdkVersion = "7.9.0"
}

extension MatomoTracker {
    /// Resets all session, visitor and campaign information.
    ///
    /// After calling this method this instance behaves like the app has been freshly installed.
    /// Events that are already queued are kept and dispatched as usual.
    public func reset() {
        withState { state in
            state.matomoUserDefaults.reset()
            state.visitor = Visitor.current(in: state.matomoUserDefaults)
            state.session = Session.current(in: state.matomoUserDefaults)
            state.dimensions = []
            state.customVariables = []
            state.campaignName = nil
            state.campaignKeyword = nil
            MatomoTracker.startNewSession(in: &state)
        }
    }
}
