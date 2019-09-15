////
////  KeyedCodableTests.swift
////  KeyedCodableTests
////
////  Created by Dariusz Grzeszczak on 26/03/2018.
////

import KeyedCodable
import XCTest

struct KeyedCodableTestHelper {

    static func checkEncode<Type: Codable>(data: Data, checkString: Bool = true, testObject: (_ codable: Type) -> Void) {

        let origString = String(data: data, encoding: .utf8)

        let codable: Type

        do {
            codable = try KeyedJSONDecoder().decode(Type.self, from: data)
        } catch {
            XCTFail("\(Type.self) cannot be parsed with error: \(error)")
            return
        }

        testObject(codable)

        guard let jsonData = try? KeyedJSONEncoder().encode(codable) else {
            XCTFail("\(Type.self) cannot be encoded")
            return
        }

        let jsonString = String(data: jsonData, encoding: .utf8)

        if checkString {
            XCTAssert(jsonString?.removedWhiteSpaces == origString?.removedWhiteSpaces,
                  "Result JSON string is different") // check the string are the same
        }

        guard let object = try? KeyedJSONDecoder().decode(Type.self, from: jsonData) else {
            XCTFail("\(Type.self) cannot be parsed second time")
            return
        }

        testObject(object)

        guard let jsonData1 = try? KeyedJSONEncoder().encode(object) else {
            XCTFail("\(Type.self) cannot be encoded second time")
            return
        }

        let jsonString1 = String(data: jsonData1, encoding: .utf8)

        XCTAssert(jsonString == jsonString1)
    }
}

extension String {
    var removedWhiteSpaces: String {
        let characters = compactMap {
            $0 == " " || $0 == "\t" || $0 == "\n" ? nil : $0
        }
        return String(characters.sorted())
    }
}
