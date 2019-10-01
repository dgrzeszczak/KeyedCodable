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
            codable = try Type.keyed.fromJSON(data)
        } catch {
            XCTFail("\(Type.self) cannot be parsed with error: \(error)")
            return
        }

        testObject(codable)

        guard let jsonString = try? codable.keyed.jsonString() else {
            XCTFail("\(Type.self) cannot be encoded")
            return
        }

        if checkString {
            XCTAssert(jsonString.removedWhiteSpaces == origString?.removedWhiteSpaces,
                  "Result JSON string is different") // check the string are the same
        }

        guard let object = try? Type.keyed.fromJSON(jsonString) else {
            XCTFail("\(Type.self) cannot be parsed second time")
            return
        }

        testObject(object)

        guard let jsonString1 = try? object.keyed.jsonString() else {
            XCTFail("\(Type.self) cannot be encoded second time")
            return
        }

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
