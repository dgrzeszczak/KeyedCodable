//
//  ZeroDecodableTests.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 06/10/2019.
//

import KeyedCodable
import XCTest

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

    func testStandardExampleWrapper() throws {
        XCTFail("not implemented")
    }

    #if swift(>=5.1)
    func testNilZeroWrapper() throws {
        XCTFail("not implemented")
    }

    func testNilInpicitZeroWrapper() throws {
        XCTFail("not implemented")
    }

    func testNilOptionalZeroWrapper() throws {
        XCTFail("not implemented")
    }

    func testEncoding() throws {
        XCTFail("not implemented")
    }
    #endif
}
