//
//  QraphQLTests.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 17/11/2021.
//
import KeyedCodable
import XCTest

struct GraphQLTestCodable: Decodable {
    public var property: Nested
    var dupa: [[Nested]]

    enum CodingKeys: String, KeyedKey {
        case property = "inner.property"
        case dupa
    }

    struct Nested: Decodable {
        let nested: String
        let id: Int
        let array: [[Int]]

        enum CodingKeys: String, KeyedKey {
            case nested = "nested.property"
            case id = "identifier"
            case array
        }
    }
}

class GraphQTests: XCTestCase {

    func testStandard() throws {
        let zero = try GraphQLDecoder()
            .build(GraphQLTestCodable.self)
            .updating([], value: "mutating query")
            .updating(["inner"], value: "innerros(param: 3)")
            .updating(["dupa", "nested"], value: "nested(para: 4)")

        print(zero.toString())
    }
}



protocol KeyPathListable {
    var allKeyPaths: [String: PartialKeyPath<Self>] { get }
}

extension KeyPathListable {

    private subscript(checkedMirrorDescendant key: String) -> Any {
        return Mirror(reflecting: self).descendant(key)!
    }

    var allKeyPaths: [String: PartialKeyPath<Self>] {
        var membersTokeyPaths = [String: PartialKeyPath<Self>]()
        let mirror = Mirror(reflecting: self)
        for case (let key?, _) in mirror.children {
            membersTokeyPaths[key] = \Self.[checkedMirrorDescendant: key] as PartialKeyPath
        }
        return membersTokeyPaths
    }

}
