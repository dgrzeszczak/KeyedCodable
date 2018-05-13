//
//  KeyOptionsTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//

import XCTest

//********** KeyOptions
// sometimes you may need to disable some of the futures above or change it's behaviour eg. dot may be used in json property identifie.
// You can configure them by KeyOptions value to the maping.

private let jsonString = """
{
    "* name": "John",
    "": {
        ".greeting": "Hallo world",
        "details": {
            "description": "Its nice here"
        }
    },
    "longitude": 3.2,
    "lattitude": 3.4,
    "array": [
    {
    "element": 1
    },
    {},
    {
    "element": 3
    },
    {
    "element": 4
    }
    ],
    "* array1": [
    {
    "element": 1
    },
    {},
    {
    "element": 3
    },
    {
    "element": 4
    }
    ]
}
"""

struct KeyOptionsExample: Codable, Keyedable {
    private(set) var greeting: String!
    private(set) var description: String!
    private(set) var name: String!
    private(set) var location: Location!
    private(set) var array: [ArrayElement]!
    private(set) var array1: [ArrayElement]!


    enum CodingKeys: String, CodingKey {
        case location = "__"
        case name = "* name"
        case greeting = "+.greeting"
        case description = ".details.description"

        case array = "### array"
        case array1 = "### * array1"

    }

    mutating func map(map: KeyMap) throws {
        try name <-> map[.name]
        try greeting <-> map[.greeting, KeyOptions(delimiter: "+", flat: nil)]
        try description <-> map[.description, KeyOptions(flat: nil)]
        try location <-> map[.location, KeyOptions(flat: "__")]
        try array <-> map[.array, KeyOptions(optionalArrayElements: "### ")]
        try array1 <-> map[.array1, KeyOptions(optionalArrayElements: "### ")]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}

class KeyOptionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testKeyOptions() {
        let jsonData = jsonString.data(using: .utf8)

        guard let test = try? JSONDecoder().decode(KeyOptionsExample.self, from: jsonData!) else {
            XCTFail("KeyOptionsExample cannot be parsed")
            return
        }

        XCTAssert(test.name == "John")

        XCTAssert(test.greeting == "Hallo world")
        XCTAssert(test.description == "Its nice here")

        XCTAssert(test.location.lattitude == 3.4)
        XCTAssert(test.location.longitude == 3.2)

        XCTAssert(test.array.count == 3)
        XCTAssert(test.array[0].element == 1)
        XCTAssert(test.array[1].element == 3)
        XCTAssert(test.array[2].element == 4)

        XCTAssert(test.array1.count == 3)
        XCTAssert(test.array1[0].element == 1)
        XCTAssert(test.array1[1].element == 3)
        XCTAssert(test.array1[2].element == 4)

        KeyedCodableTestHelper.checkEncode(codable: test)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
