//
//  Mapping.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

import Foundation

public struct Mapping {
    public let map: KeyMap
    public let key: CodingKey
    public let options: KeyOptions
}

public struct KeyOptions {
    public let delimiter: String?
    public let flat: String?
    public let optionalArrayElements: String?

    public init(delimiter: String? = ".", flat: String? = "", optionalArrayElements: String? = "* ") {
        self.delimiter = delimiter
        self.flat = flat
        self.optionalArrayElements = optionalArrayElements
    }
}

public struct KeyMap {

    public var userInfo: [CodingUserInfoKey : Any] {
        return keyMap.userInfo
    }

    public var type: MappingType {
        return keyMap.type
    }

    public subscript(key: CodingKey) -> Mapping {
        return Mapping(map: self, key: key, options: KeyOptions())
    }

    public subscript(key: CodingKey, options: KeyOptions) -> Mapping {
        return Mapping(map: self, key: key, options: options)
    }

    private let keyMap: KeyMapBase
    init(keyMap: KeyMapBase) {
        self.keyMap = keyMap
    }

    func decode<V>(object: inout V, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        try keyMap.decode(object: &object, with: keyCode, options: options)
    }
    func decode<V>(object: inout V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        try keyMap.decode(object: &object, with: keyCode, options: options)
    }
    func decode<V>(object: inout [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        try keyMap.decode(object: &object, with: keyCode, options: options)
    }
    func decode<V>(object: inout [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        try keyMap.decode(object: &object, with: keyCode, options: options)
    }
    func encode<V>(object: V, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        try keyMap.encode(object: object, with: keyCode, options: options)
    }
    func encode<V>(object: V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        try keyMap.encode(object: object!, with: keyCode, options: options)
    }
    func encode<V>(object: [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        try keyMap.encode(object: object, with: keyCode, options: options)
    }
    func encode<V>(object: [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        try keyMap.encode(object: object!, with: keyCode, options: options)
    }
}

protocol KeyMapBase {
    var userInfo: [CodingUserInfoKey: Any] { get }
    var type: MappingType { get }

    func decode<V>(object: inout V, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable
    func decode<V>(object: inout V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable

    func decode<V>(object: inout [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable
    func decode<V>(object: inout [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable

    func encode<V>(object: V, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable
    func encode<V>(object: V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable

    func encode<V>(object: [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable
    func encode<V>(object: [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable
}

extension KeyMapBase {

    func decode<V>(object: inout V, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable { }
    func decode<V>(object: inout V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable { }

    func decode<V>(object: inout [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable { }
    func decode<V>(object: inout [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable { }

    func encode<V>(object: V, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable { }
    func encode<V>(object: V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable { }

    func encode<V>(object: [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable { }
    func encode<V>(object: [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable { }
}
