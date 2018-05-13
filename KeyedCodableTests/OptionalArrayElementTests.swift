//
//  OptionalArrayElementTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//

import XCTest

// by default parsing all array will fail when any of element fail
// you can mark array an optional - so it will ommit element that couldn't be parsed (eg. some field missing)

private let jsonString = """
{
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
    ]
}
"""

struct ArrayElement: Codable {
    let element: Int
}

struct OptionalArrayElementsExample: Codable, Keyedable {
    private(set) var array: [ArrayElement]!

    enum CodingKeys: String, CodingKey {
        case array = "* array"
    }

    mutating func map(map: KeyMap) throws {
        try array <-> map[.array]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}

class OptionalArrayElementTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOptionalArrayElement() {
        let jsonData = jsonString.data(using: .utf8)

        guard let test = try? JSONDecoder().decode(OptionalArrayElementsExample.self, from: jsonData!) else {
            XCTFail("OptionalArrayElementsExample cannot be parsed")
            return
        }

        // returns array with 3 elements, empty element will be omitted
        XCTAssert(test.array.count == 3)
        XCTAssert(test.array[0].element == 1)
        XCTAssert(test.array[1].element == 3)
        XCTAssert(test.array[2].element == 4)

        KeyedCodableTestHelper.checkEncode(codable: test)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
