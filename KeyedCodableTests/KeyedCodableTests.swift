////
////  KeyedCodableTests.swift
////  KeyedCodableTests
////
////  Created by Dariusz Grzeszczak on 26/03/2018.
////

@testable import KeyedCodable
import XCTest

import Foundation

struct KeyedCodableTestHelper {

    static func checkEncode<Type: Codable>(codable: Type) {
        guard let jsonData = try? JSONEncoder().encode(codable) else {
            XCTFail("\(Type.self) cannot be encoded [checkEncode]")
            return
        }

        guard let object = try? JSONDecoder().decode(Type.self, from: jsonData) else {
            XCTFail("\(Type.self) cannot be parsed [checkEncode]")
            return
        }

        guard let jsonData1 = try? JSONEncoder().encode(object) else {
            XCTFail("\(Type.self) cannot be encoded second time [checkEncode]")
            return
        }

        let jsonString = String(data: jsonData, encoding: .utf8)
        let jsonString1 = String(data: jsonData1, encoding: .utf8)

        XCTAssert(jsonString == jsonString1)
    }
}


struct CoordinateKeyed: Codable, Keyedable {
    var latitude: Double!
    var longitude: Double!
    var elevation: Double!

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case elevation = "additionalInfo.elevation"
    }

    mutating func map(map: KeyMap) throws {
        try latitude <-> map[.latitude]
        try longitude <-> map[.longitude]
        try elevation <-> map[.elevation]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}

struct Coordinate {
    var latitude: Double
    var longitude: Double
    var elevation: Double

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case additionalInfo
    }

    enum AdditionalInfoKeys: String, CodingKey {
        case elevation
    }
}

extension Coordinate: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)

        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        elevation = try additionalInfo.decode(Double.self, forKey: .elevation)
    }
}

extension Coordinate: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)

        var additionalInfo = container.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        try additionalInfo.encode(elevation, forKey: .elevation)
    }
}

//
//private let jsonString = """
//{
//    "someString": "stringValue",
//    "someInt": 4,
//    "someBoolean": false,
//    "someClass": {
//        "booleanInClass": false,
//        "array": [
//            {
//            "element": 1
//            },
//            {},
//            {
//            "element": 3
//            },
//            {
//            "element": 4
//            }
//        ],
//        "intInClass": 3
//    },
//    "innerClassTest": {
//        "innerInt": 7,
//        "innerString": "someStringValue"
//    },
//    "longitude": 3,
//    "lattitude": 5
//}
//"""
//
//
//
//
//class Inner: Codable, Keyedable {
//
//    var intInClass: Int?
//    var booleanInClass: Bool?
//    var array: [ArrayElement]!
////    var location: Location!
//
//    required init(from decoder: Decoder) throws {
//        try KeyedDecoder(with: decoder).decode(to: self)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        try KeyedEncoder(with: encoder).encode(from: self)
//    }
//
//    init(array: [ArrayElement], location: Location) {
//        self.array = array
////        self.location = location
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case booleanInClass = "booooool"
//        case array = "* array"
//        case intInClass
////        case location = ""
//    }
//
//    func map(map: KeyMap) throws {
//        try booleanInClass <-> map[.booleanInClass]
//        try array <-> map[.array]
//        try intInClass <-> map[.intInClass]
////        try location <-> map[CodingKeys.location]
//    }
//}
//
//struct Test: Codable, Keyedable {
//    var someString: String?
//    var someInt: Int!
//    var someClass: Inner!
//
//    var innerInt: Int?
//    var innerString: String!
//
//    var location: Location!
//
//    enum CodingKeys: String, CodingKey {
//        case someString, someInt, someClass
//        case innerInt = "innerClassTest.innerInt"
//        case innerString = "innerClassTest+innerString"
//        case location = ""
//    }
//
//    init(someString: String!, someInt: Int!, someClass: Inner?, innerInt: Int?, innerString: String!, location: Location!) {
//        self.someString = someString
//        self.someInt = someInt
//        self.someClass = someClass
//        self.innerInt = innerInt
//        self.innerString = innerString
//        self.location = location
//    }
//
//    init(from decoder: Decoder) throws {
//        try KeyedDecoder(with: decoder).decode(to: &self)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        try KeyedEncoder(with: encoder).encode(from: self)
//    }
//
//    mutating func map(map: KeyMap) throws {
//        try someString <-> map[.someString]
//        try someInt <-> map[.someInt]
//        try someClass <-> map[.someClass]
//
//        try innerInt <-> map[.innerInt]
//        try innerString <-> map[.innerString, KeyOptions(delimiter: "+")]
//
//        try location <-> map[.location]
//    }
//}
//
//class KeyedCodableTests: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        let jsonData = jsonString.data(using: .utf8)
//
//        let test = try! JSONDecoder().decode(Test.self, from: jsonData!) // swiftlint:disable:this force_try
//
//        if let jsonData1 = try? JSONEncoder().encode(test) {
//            let jsonString1 = String(data: jsonData1, encoding: .utf8)
//            print(jsonString1)
//        }
//    }
//
//    func f_test2() {
//        let location = Location(lattitude: 2, longitude: 4)
//        let array = [ArrayElement(element: 6)]
//        let inner = Inner(array: array, location: location)
//        let test = Test(someString: "some",
//                        someInt: 6,
//                        someClass: inner,
//                        innerInt: 45,
//                        innerString: "innerS",
//                        location: Location(lattitude: 7, longitude: 9))
//
//        if let jsonData1 = try? JSONEncoder().encode(test) {
//            let jsonString1 = String(data: jsonData1, encoding: .utf8)
//
//            let test = try! JSONDecoder().decode(Test.self, from: jsonData1) // swiftlint:disable:this force_try
//        }
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}
