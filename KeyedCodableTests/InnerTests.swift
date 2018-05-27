//
//  InnerTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//

@testable import KeyedCodable
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

struct InnerExample: Codable, Keyedable {
    private(set) var greeting: String!
    private(set) var description: String!

    mutating func map(map: KeyMap) throws {
        try greeting <-> map["inner.greeting"]
        try description <-> map["inner.details.description"]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
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

struct ApiResponse<DataType: Codable>: Codable, Keyedable {
    // MARK: Properties
    var result: String!
    var user: User?
    var address: String!
    var data: DataType?

    mutating func map(map: KeyMap) throws {
        try result <-> map["result"]
        try address <-> map["data.user.address"]
        try user <-> map["data.user"]
        try data <-> map["data"]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
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

class InnerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
        KeyedCodableTestHelper.checkEncode(data: jsonData) { (test: OrderDataResponse) in
            XCTAssert(test.result == "OK")
            XCTAssert(test.address == "New York")
            XCTAssert(test.user?.name == "John")
            XCTAssert(test.data?.orderCount == 10)
        }
    }
}
