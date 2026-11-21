import Foundation
import Testing

/// Root suite for all MatomoTracker tests.
///
/// The SDK persists state in `UserDefaults`, which is shared between trackers with the same
/// site and url, so all nested suites run serialized instead of in parallel.
@Suite(.serialized)
enum MatomoTrackerSpecs {}

/// Polls `condition` on the main actor until it returns `true` or the timeout expires.
///
/// While waiting, the main actor is suspended, so other work can run.
/// - Returns: `true` if the condition was met before the timeout.
@MainActor
func eventually(
    timeout: TimeInterval = 5,
    pollInterval: TimeInterval = 0.01,
    _ condition: () -> Bool
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() { return true }
        try? await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
    }
    return condition()
}

/// Runs `work` on a global background queue and waits until it has finished.
func onBackgroundThread(_ work: @escaping () -> Void) async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        DispatchQueue.global(qos: .background).async {
            work()
            continuation.resume()
        }
    }
}

/// Removes all values stored in the given `UserDefaults` suite.
func removeAllInSuite(suite: String) {
    guard let userDefaults = UserDefaults(suiteName: suite) else { return }
    for key in userDefaults.dictionaryRepresentation().keys {
        userDefaults.removeObject(forKey: key)
    }
}

/// A value that can be read and changed from several threads.
final class Locked<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Value

    init(_ value: Value) {
        _value = value
    }

    var value: Value {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func mutate(_ body: (inout Value) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        body(&_value)
    }
}
