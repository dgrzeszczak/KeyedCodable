//
//  ZeroDecodableTests.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 06/10/2019.
//

import KeyedCodable
import XCTest

struct ZeroTestCodable: Codable {
    @Zero var property: Int
}

struct ZeroTestOptionalCodable: Codable {
    @Zero var property: Int?
}

struct ZeroTestImplicitCodable: Decodable {
    @Zero var property: Int?
}

class ZeroDecodableTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStandardExample() throws {
        let zero = try StandardExample.keyed.zero()
        XCTAssert(zero.inner.details.description == "")
        XCTAssert(zero.inner.greeting == "")
    }

    #if swift(>=5.1)
    func testStandardExampleWrapper() throws {
        let zero = try ZeroTestCodable.keyed.fromJSON("{ }")
        XCTAssert(zero.property == 0)
    }

    func testNilZeroWrapper() throws {
        let zero = try ZeroTestOptionalCodable.keyed.fromJSON("{ }")
        XCTAssert(zero.property == nil)
    }

    func testNilInpicitZeroWrapper() throws {
        let zero = try ZeroTestImplicitCodable.keyed.fromJSON("{ }")
        XCTAssert(zero.property == nil)
    }

    func testEncoding() throws {
        let jsonData = "{}".data(using: .utf8)!
        KeyedCodableTestHelper.checkEncode(data: jsonData, checkString: false) { (test: ZeroTestCodable) in
            XCTAssert(test.property == 0)
        }
    }

    func testNilEncoding() throws {
        let zero = try ZeroTestOptionalCodable.keyed.fromJSON("{}")
        let string = try zero.keyed.jsonString()
        XCTAssert(string == "{}")
    }
    #endif
}
