import Foundation
@testable import MatomoTracker
import Testing

extension MatomoTrackerSpecs {
    @Suite("EventAPISerializer")
    struct EventAPISerializerSpec {
        @Suite("queryItems")
        struct QueryItems {
            @Test("encodes special characters")
            func encodesSpecialCharacters() {
                let dimension = CustomDimension(index: 42, value: ###";'"|\,.<>?/+_=-)(*&^%$#@!"###)
                let event = Event.fixture(dimensions: [dimension])
                let encoded = EventAPISerializer().queryItems(for: event)
                #expect(encoded["dimension42"] == ###"%3B%27%22%7C%5C%2C.%3C%3E%3F%2F%2B_%3D-%29%28%2A%26%5E%25%24%23%40%21"###)
            }

            @Test("overrides parameters with customParameters")
            func overridesParametersWithCustomParameters() {
                let event = Event.fixture()
                let eventWithOverriddenCdt = Event.fixture(customTrackingParameters: ["cdt": "1"])
                let encodedEvent = EventAPISerializer().queryItems(for: event)
                let encodedEventWithOverriddenCdt = EventAPISerializer().queryItems(for: eventWithOverriddenCdt)

                #expect(encodedEvent["cdt"] != "1")
                #expect(encodedEventWithOverriddenCdt["cdt"] == "1")
            }

            @Test("keeps the goal revenue parameter")
            func keepsGoalRevenue() {
                let event = Event.fixture(goalId: 1, revenue: 5.0)
                let encodedEvent = EventAPISerializer().queryItems(for: event)
                #expect(encodedEvent["revenue"] == "5.0")
            }

            @Test("keeps the order revenue parameter")
            func keepsOrderRevenue() {
                let event = Event.fixture(orderRevenue: 10.0)
                let encodedEvent = EventAPISerializer().queryItems(for: event)
                #expect(encodedEvent["revenue"] == "10.0")
            }
        }
    }
}
