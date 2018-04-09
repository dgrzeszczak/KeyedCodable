//
//  KeyedCodableTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

@testable import KeyedCodable
import XCTest

import Foundation
// TODO add tests implementation

private let jsonString = """
{
    "someString": "stringValue",
    "someInt": 4,
    "someBoolean": false,
    "someClass": {
        "booleanInClass": false,
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
        "intInClass": 3
    },
    "innerClassTest": {
        "innerInt": 7,
        "innerString": "someStringValue"
    },
    "longitude": 3,
    "lattitude": 5
}
"""

struct Location: Codable {
    let lattitude: Int
    let longitude: Int
}

struct ArrayElement: Codable {
    let element: Int
}

class Inner: Codable, Keyedable {
    var intInClass: Int?
    var booleanInClass: Bool?
    var array: [ArrayElement]!
//    var location: Location!

    required init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: self)
    }

    func encode(to encoder: Encoder) throws {
        try KeyedEncoder(with: encoder).encode(from: self)
    }

    init(array: [ArrayElement], location: Location) {
        self.array = array
//        self.location = location
    }

    enum CodingKeys: String, CodingKey {
        case booleanInClass = "booooool"
        case array = "* array"
        case intInClass
//        case location = ""
    }

    func map(map: KeyMap) throws {
        try booleanInClass <-> map[CodingKeys.booleanInClass]
        try array <-> map[CodingKeys.array]
        try intInClass <-> map[CodingKeys.intInClass]
//        try location <-> map[CodingKeys.location]
    }
}

struct Test: Codable, Keyedable {
    var someString: String?
    var someInt: Int!
    var someClass: Inner!

    var innerInt: Int?
    var innerString: String!

    var location: Location!

    enum CodingKeys: String, CodingKey {
        case someString, someInt, someClass
        case innerInt = "innerClassTest.innerInt"
        case innerString = "innerClassTest+innerString"
        case location = ""
    }

    init(someString: String!, someInt: Int!, someClass: Inner?, innerInt: Int?, innerString: String!, location: Location!) {
        self.someString = someString
        self.someInt = someInt
        self.someClass = someClass
        self.innerInt = innerInt
        self.innerString = innerString
        self.location = location
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }

    func encode(to encoder: Encoder) throws {
        try KeyedEncoder(with: encoder).encode(from: self)
    }

    mutating func map(map: KeyMap) throws {
        try someString <-> map[CodingKeys.someString]
        try someInt <-> map[CodingKeys.someInt]
        try someClass <-> map[CodingKeys.someClass]

        try innerInt <-> map[CodingKeys.innerInt]
        try innerString <-> map[CodingKeys.innerString, KeyOptions(delimiter: "+")]

        try location <-> map[CodingKeys.location]
    }
}

class KeyedCodableTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let jsonData = jsonString.data(using: .utf8)

        let test = try! JSONDecoder().decode(Test.self, from: jsonData!) // swiftlint:disable:this force_try

        if let jsonData1 = try? JSONEncoder().encode(test) {
            let jsonString1 = String(data: jsonData1, encoding: .utf8)
            print(jsonString1)
        }
    }

    func f_test2() {
        let location = Location(lattitude: 2, longitude: 4)
        let array = [ArrayElement(element: 6)]
        let inner = Inner(array: array, location: location)
        let test = Test(someString: "some",
                        someInt: 6,
                        someClass: inner,
                        innerInt: 45,
                        innerString: "innerS",
                        location: Location(lattitude: 7, longitude: 9))

        if let jsonData1 = try? JSONEncoder().encode(test) {
            let jsonString1 = String(data: jsonData1, encoding: .utf8)

            let test = try! JSONDecoder().decode(Test.self, from: jsonData1) // swiftlint:disable:this force_try
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
