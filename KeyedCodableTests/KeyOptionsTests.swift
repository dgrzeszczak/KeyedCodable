//
//  KeyOptionsTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//

import KeyedCodable
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
    "latitude": 3.4,
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

struct KeyOptionsExample: Codable {
    let greeting: String
    let description: String
    let name: String
    let location: Location
    let array: [ArrayElement]
    let array1: [ArrayElement]


    enum CodingKeys: String, KeyedKey {
        case location = "__"
        case name = "* name"
        case greeting = "+.greeting"
        case description = ".details.description"

        case array = "### .array"
        case array1 = "### .* array1"

        var options: KeyOptions? {
            switch self {
            case .greeting: return KeyOptions(delimiter: .character("+"), flat: .none)
            case .description: return KeyOptions(flat: .none)
            case .location: return KeyOptions(flat: .string("__"))
            case .array, .array1: return KeyOptions(flat: .string("### "))
            default: return nil
            }
        }
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
        let jsonData = jsonString.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData, checkString: false) { (test: KeyOptionsExample) in

            XCTAssert(test.name == "John")

            XCTAssert(test.greeting == "Hallo world")
            XCTAssert(test.description == "Its nice here")

            XCTAssert(test.location.latitude == 3.4)
            XCTAssert(test.location.longitude == 3.2)

            XCTAssert(test.array.count == 3)
            XCTAssert(test.array[0].element == 1)
            XCTAssert(test.array[1].element == 3)
            XCTAssert(test.array[2].element == 4)

            XCTAssert(test.array1.count == 3)
            XCTAssert(test.array1[0].element == 1)
            XCTAssert(test.array1[1].element == 3)
            XCTAssert(test.array1[2].element == 4)
        }
    }    
}
