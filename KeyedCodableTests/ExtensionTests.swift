//
//  ExtensionTests.swift
//  KeyedCodableTests-iOS
//
//  Created by Dariusz Grzeszczak on 12/09/2019.
//

import KeyedCodable
import XCTest

struct Test: Codable {
    var property: Int
}

let singleJson = """
{
    "property":3
}
"""

let arrayJson = """
    [
        {"property":3},
        {"property":4},
        {"property":5}
    ]
"""

let valueArrayJson = """
[1, 2, 3]
"""

let intJson = "3"
let floatJson = "3.3"
let stringJson = "domek"

class ExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSingle() throws {
        var test = try? Test(fromJSON: singleJson)
        XCTAssert(test?.property == 3)

        let data = try test.jsonData()
        test = try? Test(fromJSON: data)
        XCTAssert(test?.property == 3)
    }

    func testArray() throws {
        var test = try! [Test](fromJSON: arrayJson)
        XCTAssert(test[0].property == 3)

        let data = try test.jsonData()
        test = try [Test](fromJSON: data)
        XCTAssert(test[0].property == 3)
    }

    func testValueArray() throws {
        var test = try! [Int](fromJSON: valueArrayJson)
        XCTAssert(test[1] == 2)

        let data = try test.jsonData()
        test = try [Int](fromJSON: data)
        XCTAssert(test[1] == 2)
    }

    func testIntValue() throws {
        var test = try! Int(fromJSON: intJson)
        XCTAssert(test == 3)

        let data = try test.jsonData()
        test = try Int(fromJSON: data)
        XCTAssert(test == 3)
    }

    func testFloatValue() throws {
        var test = try! Float(fromJSON: floatJson)
        XCTAssert(test == 3.3)

        let data = try test.jsonData()
        test = try Float(fromJSON: data)
        XCTAssert(test == 3.3)
    }

    func testStringValue() throws {
        var test = try! String(fromJSON: stringJson)
        XCTAssert(test == "domek")

        let data = try test.jsonData()
        test = try String(fromJSON: data)
        XCTAssert(test == "domek")
    }
}
