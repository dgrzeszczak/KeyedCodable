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

    enum CodingKeys: String, CodingKey {
        case greeting = "inner.greeting"
        case description = "inner.details.description"
    }

    mutating func map(map: KeyMap) throws {
        try greeting <-> map[CodingKeys.greeting]
        try description <-> map[CodingKeys.description]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
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

    func testInner() {
        let jsonData = jsonString.data(using: .utf8)

        guard let test = try? JSONDecoder().decode(InnerExample.self, from: jsonData!) else {
            XCTFail("InnerExample cannot be parsed")
            return
        }

        XCTAssert(test.greeting == "Hallo world")
        XCTAssert(test.description == "Its nice here")

        KeyedCodableTestHelper.checkEncode(codable: test)
    }
}
