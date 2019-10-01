//
//  ExtensionTests.swift
//  KeyedCodableTests-iOS
//
//  Created by Dariusz Grzeszczak on 12/09/2019.
//

import KeyedCodable
import XCTest

struct Model: Codable {
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
        var test = try? Model.keyed.fromJSON(singleJson)
        XCTAssert(test?.property == 3)

        let data = try test.keyed.jsonData()
        test = try? Model.keyed.fromJSON(data)
        XCTAssert(test?.property == 3)
    }

    func testArray() throws {
        var test = try! [Model].keyed.fromJSON(arrayJson)
        XCTAssert(test[0].property == 3)

        let data = try test.keyed.jsonData()
        test = try [Model].keyed.fromJSON(data)
        XCTAssert(test[0].property == 3)
    }

    func testValueArray() throws {
        var test = try! [Int].keyed.fromJSON(valueArrayJson)
        XCTAssert(test[1] == 2)

        let data = try test.keyed.jsonData()
        test = try [Int].keyed.fromJSON(data)
        XCTAssert(test[1] == 2)
    }

    func testIntValue() throws {
        var test = try! Int.keyed.fromJSON(intJson)
        XCTAssert(test == 3)

        let data = try test.keyed.jsonData()
        test = try Int.keyed.fromJSON(data)
        XCTAssert(test == 3)
    }

    func testFloatValue() throws {
        var test = try! Float.keyed.fromJSON(floatJson)
        XCTAssert(test == 3.3)

        let data = try test.keyed.jsonData()
        test = try Float.keyed.fromJSON(data)
        XCTAssert(test == 3.3)
    }

    func testStringValue() throws {
        var test = try! String.keyed.fromJSON(stringJson)
        XCTAssert(test == "domek")

        let data = try test.keyed.jsonData()
        test = try String.keyed.fromJSON(data)
        XCTAssert(test == "domek")
    }
}
