//
//  OptionalDictionaryElementsTests.swift
//  KeyedCodableTests-iOS
//
//  Created by Dariusz Grzeszczak on 19/11/2020.
//

import XCTest
@testable import  KeyedCodable

private let jsonString = """
{
    "translations": {
        "name": [
            {
                "type": "heading1",
                "text": "Translations",
                "spans": []
            }
        ],
        "courses_tile_lessons": "lessons",
        "courses_tile_progress": "progress",
        "courses_tile_new_content": "new cotes",
        "time_minute_full_singular": "minute",
        "time_minute_medium_plural": "min",
        "time_minute_medium_singular": "min",
        "time_minute_short_plural": "m",
        "time_minute_short_singular": "m",
        "time_hour_full_plural": "hours",
        "time_hour_full_singular": "hour",
        "time_hour_medium_plural": "hrs",
        "time_hour_medium_singular": "hr",
        "time_hour_short_plural": "h",
        "time_hour_short_singular": "h",
        "commitment_make": "Make commitment",
        "commitment_made": "Commitment made",
        "commitment_view_all": "View all",
        "engaged-3-days": "You're on a 3 day streak!",
        "engaged-3-weeks": "You're on a 3 weeks streak!",
        "engaged-2-months": "You're on a 2 months streak!",
        "engaged-1-year": "Wow, 1 year with us!",
        "notifications_enabled_alert": "It appears that you have disabled notification in the system settings, please keep in mind you won't receive any despite enabling them on the server side. If you'd like to change that please click here?"
    }
}
"""

enum TranslationKeys: String, Codable {
    case courses_tile_lessons
    case time_minute_short_singular
}

struct Translations: Codable {
    @Flat var translations: [TranslationKeys: String]
}

struct Translations1: Codable {
    @Flat var translations: [String: String]?
}

struct Translations2: Codable {
    let translations: [String: String]

    enum CodingKeys: String, KeyedKey {
        case translations = ".translations"
    }
}

class OptionalDictionaryElementsTests: XCTestCase {



    func testBackwardCompatibility_3_1_2() throws {
        let string = "some string value"
        let stringData1 = try! Data.from(string: string) // old case
        let stringData2 = try! JSONEncoder().encode(string)

        let int = 3
        let int1Data = try! Data.from(string: "\(int)")
        let int2Data = try! JSONEncoder().encode(int)

        let double = 3.4
        let double1Data = try! Data.from(string: (double as LosslessStringConvertible).description)
        let double2Data = try! JSONEncoder().encode(double)

        let string1 = try! KeyedJSONDecoder().decode(String.self, from: stringData1)
        let string2 = try! KeyedJSONDecoder().decode(String.self, from: stringData2)

        let int1 = try! KeyedJSONDecoder().decode(Int.self, from: int1Data)
        let int2 = try! KeyedJSONDecoder().decode(Int.self, from: int2Data)

        let double1 = try! KeyedJSONDecoder().decode(Double.self, from: double1Data)
        let double2 = try! KeyedJSONDecoder().decode(Double.self, from: double2Data)

        XCTAssert(string == string1 && string1 == string2)
        XCTAssert(int == int1 && int1 == int2)
        XCTAssert(double == double1 && double1 == double2)
    }
    func testExample() throws {

        //let translations = try! Translations.keyed.fromJSON(jsonString)
        let translations1 = try! Translations1.keyed.fromJSON(jsonString)
        //let translations2 = try! Translations2.keyed.fromJSON(jsonString)
        print("kjhkjhk")
    }



}
