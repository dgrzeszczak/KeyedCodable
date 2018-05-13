//
//  FlatTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//

import XCTest

//!!!!! it's recomended to use before other mappings (on begining of map() function)
//!!!!! due to swift issue it may throw strange error when used after "optional array elements" mapping
//
// ==== it seems it is fixed in swift 4.1

//
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
    let longitude: Double
}

struct InnerWithFlatExample: Codable, Keyedable {
    private(set) var greeting: String!
    private(set) var location: Location?

    enum CodingKeys: String, CodingKey {
        case greeting = "inner.greeting"
        case location = ""
    }

    mutating func map(map: KeyMap) throws {
        try greeting <-> map[.greeting]
        try location <-> map[.location]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
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
        let jsonData = jsonString.data(using: .utf8)

        guard let test = try? JSONDecoder().decode(InnerWithFlatExample.self, from: jsonData!) else {
            XCTFail("InnerWithFlatExample cannot be parsed")
            return
        }

        XCTAssert(test.greeting == "hallo")
        XCTAssert(test.location?.lattitude == 3.4)
        XCTAssert(test.location?.longitude == 3.2)

        KeyedCodableTestHelper.checkEncode(codable: test)
    }
}
