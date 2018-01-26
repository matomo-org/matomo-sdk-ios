@testable import MatomoTracker
import Quick
import Nimble

class EventSerializerSpec: QuickSpec {
    override func spec() {
        describe("jsonEncoded") {
            let tracker = MatomoTracker(siteId: "spec_id", baseURL: URL(string: "https://speck.domain.com/piwik.php")!)
            let serializer = EventSerializer()
            it("should encode & characters") {
                let event = Event(tracker: tracker, action: ["_specs_&_specs_"])
                let encoded = String(data: try! serializer.jsonData(for: [event]), encoding: String.Encoding.utf8)
                expect(encoded).to(contain("_specs_%26_specs_"))
            }
            it("should encode / characters") {
                let event = Event(tracker: tracker, action: ["_specs_/_specs_"])
                let encoded = String(data: try! serializer.jsonData(for: [event]), encoding: String.Encoding.utf8)
                expect(encoded).to(contain("_specs_%2F_specs_"))
            }
            it("should encode ? characters") {
                let event = Event(tracker: tracker, action: ["_specs_?_specs_"])
                let encoded = String(data: try! serializer.jsonData(for: [event]), encoding: String.Encoding.utf8)
                expect(encoded).to(contain("_specs_%253F_specs_"))
            }
        }
    }
}
