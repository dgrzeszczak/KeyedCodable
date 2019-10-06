//
//  InnerTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//

import KeyedCodable
import XCTest

private let jsonString = """
{
    "inner": {
        "greeting": "Hallo world",
        "details": {
            "description": "Its nice here"
        }
    }
}
"""

struct StandardExample: Codable {
    let inner: Inner

    struct Inner: Codable {
        let greeting: String
        let details: Details
    }

    struct Details: Codable {
        let description: String
    }
}

struct InnerExample: Codable {
    let greeting: String
    let description: String

    enum CodingKeys: String, KeyedKey {
        case greeting = "inner.greeting"
        case description = "inner.details.description"
    }
}

struct InnerExample1: Codable {

    let greeting: String
    let description: String
    let details: Details

    struct Details: Codable {
        enum CodingKeys: String, KeyedKey {
            case description = "details.description"
        }
        let description: String
    }

    enum CodingKeys: String, KeyedKey {
        case greeting = "inner.greeting"
        case description = "inner.details.description"
        case details = "inner"
    }
}


//MARK: second
struct User: Codable {
    var name: String?
}

typealias OrderDataResponse = ApiResponse<OrderData>

struct OrderData: Codable {
    var orderCount: Int
}

struct ApiResponse<DataType: Codable>: Codable {
    // MARK: Properties
    var result: String
    var user: User?
    var address: String
    var data: DataType?

    enum CodingKeys: String, KeyedKey {
        case result
        case user = "data.user"
        case address = "data.user.address"
        case data
    }
}

let orderDataResponseJson = """
{
    "result":"OK",
    "data":{
        "user": {
            "name":"John",
            "address":"New York"
        },
        "orderCount":10
    }
}
"""

struct Empty: Codable { }
struct NilOnly: Codable {
    let nilValue: Int?
}

class InnerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEmpty() {
        let jsonData = "{}".data(using: .utf8)!
        KeyedCodableTestHelper.checkEncode(data: jsonData) { (test: Empty) in }
    }

    func testNilEncoding() throws {
        let value = NilOnly(nilValue: nil)
        let stringValue = try value.keyed.jsonString()
        XCTAssert(stringValue == "{}")
    }

    func testEmptyNil() {
        let jsonData = "{}".data(using: .utf8)!
        KeyedCodableTestHelper.checkEncode(data: jsonData) { (test: NilOnly) in }
    }

    func testInner() {
        let jsonData = jsonString.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData) { (test: InnerExample) in
            XCTAssert(test.greeting == "Hallo world")
            XCTAssert(test.description == "Its nice here")
        }
    }

    func testResponse() {
        let jsonData = orderDataResponseJson.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData, checkString: false) { (test: OrderDataResponse) in
            XCTAssert(test.result == "OK")
            XCTAssert(test.address == "New York")
            XCTAssert(test.user?.name == "John")
            XCTAssert(test.data?.orderCount == 10)
        }
    }

    func testStandard() {
        let jsonData = jsonString.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData) { (test: StandardExample) in
            XCTAssert(test.inner.greeting == "Hallo world")
            XCTAssert(test.inner.details.description == "Its nice here")
        }
    }

    func testInner1() {
        let jsonData = jsonString.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData) { (test: InnerExample1) in
            XCTAssert(test.greeting == "Hallo world")
            XCTAssert(test.description == "Its nice here")
            XCTAssert(test.details.description == "Its nice here")
        }
    }
}
