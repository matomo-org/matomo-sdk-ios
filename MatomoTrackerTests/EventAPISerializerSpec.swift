@testable import MatomoTracker
import Quick
import Nimble

class EventAPISerializerSpec: QuickSpec {
    override func spec() {
        describe("queryItems") {
            it("encodes special characters") {
                let dimension = CustomDimension(index: 42, value: ###";'"|\,.<>?/+_=-)(*&^%$#@!"###)
                let event = Event.fixture(dimensions: [dimension])
                let encoded = EventAPISerializer().queryItems(for: event)
                expect(encoded["dimension42"]) == ###"%3B%27%22%7C%5C%2C.%3C%3E%3F%2F%2B_%3D-%29%28%2A%26%5E%25%24%23%40%21"###
            }
            it("overrides parameters with customParameters") {
                let event = Event.fixture()
                let eventWithOverriddenCdt = Event.fixture(customTrackingParameters: ["cdt": "1"])
                let encodedEvent = EventAPISerializer().queryItems(for: event)
                let encodedEventWithOverriddenCdt = EventAPISerializer().queryItems(for: eventWithOverriddenCdt)
                
                expect(encodedEvent["cdt"]) != "1"
                expect(encodedEventWithOverriddenCdt["cdt"]) == "1"
            }
        }
    }
}
