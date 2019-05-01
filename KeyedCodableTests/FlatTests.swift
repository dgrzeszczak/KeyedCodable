//
//  FlatTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//

import KeyedCodable
import XCTest

private let jsonString = """
{
    "inner": {
        "greeting": "hallo"
    },
    "longitude": 3.2,
    "lattitude": 3.4
}
"""

struct Location: Codable {
    let lattitude: Double
    let longitude: Double?
}

struct InnerWithFlatExample: Codable {
    let greeting: String
    let location: Location?

    enum CodingKeys: String, KeyedKey {
        case greeting = "inner.greeting"
        case location = ""
    }
}

class FlatTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFlat() {
        let jsonData = jsonString.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData, checkString: false) { (test: InnerWithFlatExample) in
            XCTAssert(test.greeting == "hallo")
            XCTAssert(test.location?.lattitude == 3.4)
            XCTAssert(test.location?.longitude == 3.2)
        }
    }
}
