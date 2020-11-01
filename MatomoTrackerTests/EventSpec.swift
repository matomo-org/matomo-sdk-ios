//
//  EventSpec.swift
//  MatomoTrackerTests
//
//  Created by Svyatoshenko "Megal" Misha on 09/09/2019.
//  Copyright © 2019 Matomo. All rights reserved.
//

@testable import MatomoTracker
import Quick
import Nimble

class EventSpec: QuickSpec {
    override func spec() {
        var tracker: MatomoTracker!

        beforeEach {
            tracker = MatomoTracker(siteId: "5", baseURL: URL(string: "https://example.com/matomo.php")!)
        }

        describe("event with custom dimentions") {
            func makeEvent(with customDimentsions: CustomDimension...) -> Event {
                return Event(tracker: tracker, action: ["action"], dimensions: customDimentsions)
            }


            context("with alphanumeric values") {
                var testString: String!
                var eventDataString: Result<String, Error> = .failure(ConvertError.stringInitFailed)
                var event: Event!

                enum ConvertError: Error {
                    case stringInitFailed
                }

                beforeEach {
                    testString = "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
                    event = makeEvent(with: .init(index: 42, value: testString))

                    let eventData = Result {
                        try EventAPISerializer().jsonData(for: [event])
                    }

                    eventDataString = eventData.flatMap { data in
                        return Result<String, Error> {
                            if let dataString = String(data: data, encoding: .utf8) {
                                return dataString
                            } else {
                                throw ConvertError.stringInitFailed as Error
                            }
                        }
                    }

                }

                it("can be serialized as json in string representation") {
                    expect(try? eventDataString.get()).toNot(beNil())
                }

                it("has value in queryString unescaped") {
                    expect(try? eventDataString.get().contains(testString)).to(beTrue())
                }
            }

            context("with special characters") {
                var testString: String!
                var testStringEscaped: String!
                var eventDataString: Result<String, Error> = .failure(ConvertError.stringInitFailed)
                var event: Event!

                enum ConvertError: Error {
                    case stringInitFailed
                }

                beforeEach {
                    testString = ###";'"|\,.<>?/+_=-)(*&^%$#@!"###
                    // From https://www.urlencoder.org/
                    testStringEscaped = ###"%3B%27%22%7C%5C%2C.%3C%3E%3F%2F%2B_%3D-%29%28%2A%26%5E%25%24%23%40%21"###
                    event = makeEvent(with: .init(index: 42, value: testString))

                    let eventData = Result {
                        try EventAPISerializer().jsonData(for: [event])
                    }

                    eventDataString = eventData.flatMap { data in
                        return Result<String, Error> {
                            if let dataString = String(data: data, encoding: .utf8) {
                                return dataString
                            } else {
                                throw ConvertError.stringInitFailed as Error
                            }
                        }
                    }

                }

                it("can be serialized as json in string representation") {
                    expect(try? eventDataString.get()).toNot(beNil())
                }

                it("doesn't have value in queryString unescaped") {
                    expect(try? eventDataString.get().contains(testString)).to(beFalse())
                }

                it("has value in queryString escaped") {
                    expect(try? eventDataString.get().contains(testStringEscaped)).to(beTrue())
                }
            }
        }
    }
}
