//
//  TransformersTests.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 06/10/2019.
//

import KeyedCodable
import XCTest

#if swift(>=5.1)
struct NotCodable {
    let id: Int
}

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
    "date2": "2012-05-03",

"lat": 1,
"array": [{"o": 1}, { }, { "o":2 }]
}
"""

struct TextCodableTrasform: Codable {

//    @CodedBy<MyDateFormatter> var date0: Date!
//    @CodedBy<MyDateFormatter> var date1: Date
//    @CodedBy<MyDateFormatter> var date2: Date!
//    @CodedBy<MyDateFormatter> var date5: Date?
//    @Flat var loc: Loc

    //var date8: TestNil?

}

class TransformersTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testTransformDates() {
        XCTFail("not implemented")
//        //let container = TextCodableTrasform(test: NotCodable(d: 8))
//        let data = dates.data(using: .utf8)!
//        var second = try! TextCodableTrasform(fromJSON: dates)
//        //print(second.date0)
//        //print(second.date1)
//        //print(second.date2)
////        print(second.date5)
//        let string = try! String(data: KeyedJSONEncoder().encode(second), encoding: .utf8) //second.keyed.jsonString()
//        print(string)
//        //let zero = try! TextCodableTrasform.keyed.zero()
//        //print(zero)
//        let d = 3
    }

    func testTransformNotCodable() {
        XCTFail("not implemented")
    }

    func testTransformOptionalNilEncoding() {
        XCTFail("not implemented")
    }
}
#endif
