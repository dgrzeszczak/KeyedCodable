//
//  KeyedJSONDecoder.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

open class KeyedJSONDecoder: JSONDecoder {

    open override func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {

        if T.self == String.self {
            return try String.from(data: data) as! T
        } else if T.self == Int.self {
            guard let int = try Int(String.from(data: data)) else { throw KeyedCodableError.stringParseFailed }
            return int as! T
        } else if let type = T.self as? LosslessStringConvertible.Type {
            guard let lossless = try type.init(String.from(data: data)) else { throw KeyedCodableError.stringParseFailed }
            return lossless as! T
        } else {
            return try super.decode(Keyed<T>.self, from: data).value
        }
    }
}

extension Decodable {

    public static var keyed: Keyed<Self>.Type { return Keyed.self }

    @available(*, deprecated, message: "Use DecodableType.keyed.fromJSON() instead. Replace all occurences of '(fromJSON: ' with '.keyed.fromJSON('.")
    public init(fromJSON data: Data, decoder: KeyedJSONDecoder = KeyedConfig.default.defaultJSONDecoder()) throws {

        self = try Self.keyed.fromJSON(data, decoder: decoder)
    }

    @available(*, deprecated, message: "Use DecodableType.keyed.fromJSON() instead. Replace all occurences of '(fromJSON: ' with '.keyed.fromJSON('.")
    public init(fromJSON string: String, encoding: String.Encoding = .utf8, decoder: KeyedJSONDecoder = KeyedConfig.default.defaultJSONDecoder()) throws {

        self = try Self.keyed.fromJSON(string, encoding: encoding, decoder: decoder)
    }
}

extension Keyed where Base: Decodable {

    public static func fromJSON(_ data: Data, decoder: KeyedJSONDecoder = KeyedConfig.default.defaultJSONDecoder()) throws -> Base {

        return try decoder.decode(Base.self, from: data)
    }

    public static func fromJSON(_ string: String, encoding: String.Encoding = .utf8, decoder: KeyedJSONDecoder = KeyedConfig.default.defaultJSONDecoder()) throws -> Base {
        return try fromJSON(Data.from(string: string, encoding: encoding), decoder: decoder)
    }
}

extension Keyed: Decodable where Base: Decodable {
    public init(from decoder: Decoder) throws {
        if let keyedDecoder = decoder as? KeyedDecoder {
            value = try keyedDecoder.singleValueContainer().decode(Base.self)
        } else {
            value = try Base(from: KeyedDecoder(decoder: decoder, codingPath: decoder.codingPath))
        }
    }
}

// MARK: internal

struct KeyedDecoder: Decoder {
    let decoder: Decoder
    let codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any] { return decoder.userInfo }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return try KeyedDecodingContainer(KeyedKeyedDecodingContainer(keyedDecoder: self))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try KeyedUnkeyedDecodingContainer(keyedDecoder: self)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return try KeyedSingleValueDecodingContainer(keyedDecoder: self)
    }
}

struct KeyedSingleValueDecodingContainer: SingleValueDecodingContainer {

    private let keyedDecoder: KeyedDecoder
    private let container: SingleValueDecodingContainer

    var codingPath: [CodingKey] { return keyedDecoder.codingPath }

    init(keyedDecoder: KeyedDecoder) throws {
        self.keyedDecoder = keyedDecoder
        container = try keyedDecoder.decoder.singleValueContainer()
    }

    func decodeNil() -> Bool {
        return container.decodeNil()
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try container.decode(type)
    }

    func decode(_ type: String.Type) throws -> String {
        return try container.decode(type)
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try container.decode(type)
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try container.decode(type)
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try container.decode(type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try container.decode(type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try container.decode(type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try container.decode(type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try container.decode(type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try container.decode(type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try container.decode(type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try container.decode(type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try container.decode(type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try container.decode(type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T(from: keyedDecoder)
    }
}

struct KeyedUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    private let keyedDecoder: KeyedDecoder
    private var container: UnkeyedDecodingContainer

    init(keyedDecoder: KeyedDecoder) throws {
        self.keyedDecoder = keyedDecoder
        container = try keyedDecoder.decoder.unkeyedContainer()
    }

    var codingPath: [CodingKey] { return keyedDecoder.codingPath }

    var count: Int? { return container.count }

    var isAtEnd: Bool { return container.isAtEnd }

    var currentIndex: Int { return container.currentIndex }

    mutating func decodeNil() throws -> Bool {
        return try container.decodeNil()
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try container.decode(type)
    }

    mutating func decode(_ type: String.Type) throws -> String {
        return try container.decode(type)
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        return try container.decode(type)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        return try container.decode(type)
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        return try container.decode(type)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try container.decode(type)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try container.decode(type)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try container.decode(type)
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try container.decode(type)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try container.decode(type)
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try container.decode(type)
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try container.decode(type)
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try container.decode(type)
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try container.decode(type)
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T(from: superDecoder())
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return try KeyedDecodingContainer(KeyedKeyedDecodingContainer<NestedKey>(keyedDecoder: superDecoder() as! KeyedDecoder))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try KeyedUnkeyedDecodingContainer(keyedDecoder: superDecoder() as! KeyedDecoder)
    }

    mutating func superDecoder() throws -> Decoder {
        let decoder = try container.superDecoder()
        let lastPath = decoder.codingPath[decoder.codingPath.count - 1]
        return KeyedDecoder(decoder: decoder, codingPath: codingPath + [lastPath])
    }
}

final class KeyedKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {

    private let keyedDecoder: KeyedDecoder
    private var container: KeyedDecodingContainer<AnyKey>

    init(keyedDecoder: KeyedDecoder) throws {
        self.keyedDecoder = keyedDecoder
        container = try keyedDecoder.decoder.container(keyedBy: AnyKey.self)
    }

    var codingPath: [CodingKey] { return keyedDecoder.codingPath }

    var allKeys: [K] {
        guard let type = K.self as? CaseIterableKey.Type else { return container.allKeys.compactMap(K.init) }
        return type.allKeys.compactMap { K(stringValue: $0.stringValue) }.filter(contains)
    }

    func contains(_ key: K) -> Bool {
        if key.isFlat { return true }
        guard let contanerWithKey = try? boxedContainer(for: key) else { return false }
        return contanerWithKey.0.contains(contanerWithKey.1)
    }

    func decodeNil(forKey key: K) throws -> Bool {
        if key.isFlat { return false }
        guard contains(key) else { return true }
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decodeNil(forKey: contanerWithKey.1)
    }

    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: String.Type, forKey key: K) throws -> String {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        let contanerWithKey = try boxedContainer(for: key)
        return try contanerWithKey.0.decode(type, forKey: contanerWithKey.1)
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        #if swift(>=5.1)
        if let type = type as? FlatType.Type {
            if type.isArray {
                return try T(from: superDecoder(forKey: key))
            } else {
                return try T(from: keyedDecoder)
            }
        } else {
            return try decodeArray(type, forKey: key) ?? T(from: superDecoder(forKey: key))
        }
        #else
            return try decodeArray(type, forKey: key) ?? T(from: superDecoder(forKey: key))
        #endif
    }

    private func decodeArray<T>(_ type: T.Type, forKey key: K) throws -> T? where T : Decodable {
        if let type = type as? _Array.Type, key.isFirstFlat {
            return type.optionalDecode(unkeyedContainer: try nestedUnkeyedContainer(forKey: key))
        }
        return nil
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        if key.isFlat {
            return try? decode(type, forKey: key)
        } else if try decodeNil(forKey: key) {
            return .none
        } else {
            return try decode(type, forKey: key)
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let decoder = try superDecoder(forKey: key)
        return try KeyedDecodingContainer(KeyedKeyedDecodingContainer<NestedKey>(keyedDecoder: decoder as! KeyedDecoder))
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        let decoder = try superDecoder(forKey: key)
        return try KeyedUnkeyedDecodingContainer(keyedDecoder: decoder as! KeyedDecoder)
    }

    func superDecoder() throws -> Decoder {
        let decoder = try container.superDecoder()
        return KeyedDecoder(decoder: decoder, codingPath: codingPath + [AnyKey.superKey])
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        if key.isFlat {
            return keyedDecoder
        } else if key.isFirstFlat {
            let contanerWithKey = try boxedContainer(for: Array(key.keyed.dropFirst()))
            let decoder = try contanerWithKey.0.superDecoder(forKey: contanerWithKey.1)
            return KeyedDecoder(decoder: decoder, codingPath: codingPath + [key])
        } else {
            let contanerWithKey = try boxedContainer(for: key)
            let decoder = try contanerWithKey.0.superDecoder(forKey: contanerWithKey.1)
            return KeyedDecoder(decoder: decoder, codingPath: codingPath + [key])
        }
    }

    private func boxedContainer(for key: K) throws -> (KeyedDecodingContainer<AnyKey>, AnyKey) {
        guard let _ = K.self as? AnyKeyedKey.Type else { return (self.container, AnyKey(key: key)) }
        return try boxedContainer(for: key.keyed)
    }

    private func boxedContainer(for keyPath: [AnyKey]) throws -> (KeyedDecodingContainer<AnyKey>, AnyKey) {
        var keys: [AnyKey] = keyPath

        let key = keys.removeLast()
        var container = self.container

        try keys.forEach {
            container = try container.nestedContainer(keyedBy: AnyKey.self, forKey: $0)
        }

        return (container, key)
    }
}
