//
//  OptionalArrayElementTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//

import XCTest
import KeyedCodable

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

struct OptionalArrayElementsExample: Codable {
    let array: [ArrayElement]

    enum CodingKeys: String, KeyedKey {
        case array = ".array"
    }
}

#if swift(>=5.1)
struct OptionalArrayElementsWrapperExample: Codable {

    @Flat private(set) var array: [ArrayElement]

}
#endif

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
        let jsonData = jsonString.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: jsonData, checkString: false) { (test: OptionalArrayElementsExample) in
            // returns array with 3 elements, empty element will be omitted
            XCTAssert(test.array.count == 3)
            XCTAssert(test.array[0].element == 1)
            XCTAssert(test.array[1].element == 3)
            XCTAssert(test.array[2].element == 4)
        }
    }

    #if swift(>=5.1)
    func testOptionalArrayElementWrapper() {
       let jsonData = jsonString.data(using: .utf8)!

       KeyedCodableTestHelper.checkEncode(data: jsonData, checkString: false) { (test: OptionalArrayElementsWrapperExample) in
           // returns array with 3 elements, empty element will be omitted
           XCTAssert(test.array.count == 3)
           XCTAssert(test.array[0].element == 1)
           XCTAssert(test.array[1].element == 3)
           XCTAssert(test.array[2].element == 4)
       }
    }
    #endif
}
