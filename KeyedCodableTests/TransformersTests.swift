//
//  TransformersTests.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 06/10/2019.
//

import KeyedCodable
import XCTest

#if swift(>=5.1)

let notCodable = """
{
    "some": 3
}
"""
struct NotCodable {
    let id: Int
}

enum NonCodableTransformer<Object>: Transformer {
    static func transform(from decodable: Int) -> Any? {
        return NotCodable(id: decodable)
    }

    static func transform(object: Object) -> Int? {
        return (object as? NotCodable)?.id
    }
}

struct SomeCodable: Codable {

    @CodedBy<NonCodableTransformer> var some: NotCodable
}


//Dates
enum DateTransformer<Object>: Transformer {

    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static func transform(from decodable: String) -> Any? {
        return formatter.date(from: decodable)
    }

    static func transform(object: Object) -> String? {
        guard let object = object as? Date else { return nil }
        return formatter.string(from: object)
    }
}

let dates = """
{
    "date0": "2012-05-01",
    "date1": "2012-05-02",
    "date2": "2012-05-03"
}
"""

struct DateCodableTrasform: Codable {

    @CodedBy<DateTransformer> var date0: Date!
    @CodedBy<DateTransformer> var date1: Date
    @CodedBy<DateTransformer> var date2: Date?
    @CodedBy<DateTransformer> var date3: Date?
}

struct DateCodableTransform: Codable {
    @CodedBy<DateTransformer> var date4: Date!
}

class TransformersTests: XCTestCase {

    func testTransformDates() throws {
        let jsonData = dates.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData, checkString: false) { (test: DateCodableTrasform) in
            XCTAssert(test.date0.timeIntervalSince1970 == 1335823200)
            XCTAssert(test.date1 == Date(timeIntervalSince1970: 1335909600))
            XCTAssert(test.date2 == Date(timeIntervalSince1970: 1335996000))
            XCTAssert(test.date3 == nil)
        }
    }

    func testTransformOptionalNilEncoding() throws {

        let date = try DateCodableTransform.keyed.fromJSON("{}")
        let string = try date.keyed.jsonString()
        XCTAssert(string == "{}")
    }

    func testTransformNotCodable() {
        let jsonData = notCodable.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData, checkString: false) { (test: SomeCodable) in
            XCTAssert(test.some.id == 3)
        }
    }
}
#endif
