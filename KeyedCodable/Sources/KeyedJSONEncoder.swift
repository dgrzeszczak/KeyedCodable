////
////  KeyedJSONEncoder.swift
////  KeyedCodable
////
////  Created by Dariusz Grzeszczak on 26/03/2018.
////  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
////
//
import Foundation

open class KeyedJSONEncoder: JSONEncoder {

    open override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        if let string = value as? String {
            return try Data.from(string: string)
        } else if let int = value as? Int {
            return try Data.from(string: "\(int)")
        } else if let lossless = value as? LosslessStringConvertible {
            return try Data.from(string: lossless.description)
        } else {
            return try super.encode(Keyed(value))
        }
    }
}

extension Encodable {

    public var keyed: Keyed<Self> { return Keyed(self) }

    @available(*, deprecated, message: "Use keyed.jsonData() instead")
    public func jsonData(encoder: KeyedJSONEncoder = KeyedConfig.default.defaultJSONEncoder()) throws -> Data {

        return try keyed.jsonData(encoder: encoder)
    }

    @available(*, deprecated, message: "Use keyed.jsonString() instead")
    public func jsonString(encoding: String.Encoding = .utf8, encoder: KeyedJSONEncoder = KeyedConfig.default.defaultJSONEncoder()) throws -> String {

        return try keyed.jsonString(encoding: encoding, encoder: encoder)
    }
}

extension Keyed where Base: Encodable {

    public func jsonData(encoder: KeyedJSONEncoder = KeyedConfig.default.defaultJSONEncoder()) throws -> Data {
        return try encoder.encode(value)
    }

    public func jsonString(encoding: String.Encoding = .utf8, encoder: KeyedJSONEncoder = KeyedConfig.default.defaultJSONEncoder()) throws -> String {
        let data = try encoder.encode(value)
        return try String.from(data: data, encoding: encoding)
    }
}

extension Keyed: Encodable where Base: Encodable {
    public func encode(to encoder: Encoder) throws {
        if let keyedEncoder = encoder as? KeyedEncoder {
            try value.encode(to: keyedEncoder)
        } else {
            try value.encode(to: KeyedEncoder(encoder: encoder, codingPath: encoder.codingPath, cache: nil))
        }
    }
}

// MARK: internal

struct KeyedEncoder: Encoder {

    let encoder: Encoder
    let codingPath: [CodingKey]

    let cache: (() -> KeyedEncodingContainerCache)?

    var userInfo: [CodingUserInfoKey : Any] { return encoder.userInfo }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let cache = self.cache?() ?? {
            let cache = KeyedEncodingContainerCache(encoder: encoder)
            _ = cache.container // always initialize cotainer for top-level cache
            return cache
        }()
        return KeyedEncodingContainer(KeyedKeyedEncodingContainer<Key>(keyedEncoder: self, cache: cache))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return KeyedUnkeyedEncodingContainer(keyedEncoder: self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return KeyedSingleValueEncodingContainer(keyedEncoder: self)
    }
}

struct KeyedSingleValueEncodingContainer: SingleValueEncodingContainer {
    private(set) var container: SingleValueEncodingContainer
    let keyedEncoder: KeyedEncoder

    var codingPath: [CodingKey] { return keyedEncoder.codingPath }

    init(keyedEncoder: KeyedEncoder) {
        self.keyedEncoder = keyedEncoder
        container = keyedEncoder.encoder.singleValueContainer()
    }

    mutating func encodeNil() throws {
        try container.encodeNil()
    }

    mutating func encode(_ value: Bool) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: String) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Double) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Float) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int8) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int16) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int32) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int64) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt8) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt16) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt32) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt64) throws {
        try container.encode(value)
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        try value.encode(to: keyedEncoder)
    }
}

struct KeyedUnkeyedEncodingContainer: UnkeyedEncodingContainer {

    let keyedEncoder: KeyedEncoder
    private(set) var container: UnkeyedEncodingContainer

    var codingPath: [CodingKey] { return keyedEncoder.codingPath }

    init(keyedEncoder: KeyedEncoder) {
        self.keyedEncoder = keyedEncoder
        container = keyedEncoder.encoder.unkeyedContainer()
    }

    var count: Int { return container.count }

    mutating func encodeNil() throws {
        try container.encodeNil()
    }

    mutating func encode(_ value: String) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Double) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Float) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int8) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int16) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int32) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Int64) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt8) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt16) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt32) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: UInt64) throws {
        try container.encode(value)
    }

    mutating func encode(_ value: Bool) throws {
        try container.encode(value)
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        return try value.encode(to: superEncoder())
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {

        let encoder = superEncoder() as! KeyedEncoder
        return encoder.container(keyedBy: NestedKey.self)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let encoder = superEncoder() as! KeyedEncoder
        return encoder.unkeyedContainer()
    }

    mutating func superEncoder() -> Encoder {
        let encoder = container.superEncoder()
        let lastPath = encoder.codingPath[encoder.codingPath.count - 1]
        return KeyedEncoder(encoder: encoder, codingPath: keyedEncoder.codingPath + [lastPath], cache: nil)
    }
}

final class KeyedKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {

    private let keyedEncoder: KeyedEncoder
    private(set) var cache: KeyedEncodingContainerCache

    init(keyedEncoder: KeyedEncoder, cache: KeyedEncodingContainerCache) {
        self.keyedEncoder = keyedEncoder
        self.cache = cache
    }
    
    var codingPath: [CodingKey] { return keyedEncoder.codingPath }

    private func keyPath(forKey key: K) -> [AnyKey] {
        guard let _ = K.self as? AnyKeyedKey.Type else { return [AnyKey(key: key)] }
        return key.keyed
    }

    func encodeNil(forKey key: K) throws {
        try cache.encodeNil(for: keyPath(forKey: key))
    }

    func encode(_ value: Bool, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: String, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: Double, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: Float, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: Int, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: Int8, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: Int16, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: Int32, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: Int64, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: UInt, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: UInt8, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: UInt16, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: UInt32, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode(_ value: UInt64, forKey key: K) throws {
        try cache.encode(value, for: keyPath(forKey: key))
    }

    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        #if swift(>=5.1)
        if (value as? Nullable)?.isNil == true  {
            // do not encode null as standard library
        } else if let type = T.self as? FlatType.Type, !type.isArray {
            try value.encode(to: keyedEncoder)
        } else {
            try value.encode(to: superEncoder(forKey: key))
        }
        #else
            try value.encode(to: superEncoder(forKey: key))
        #endif
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {

        let encoder = superEncoder() as! KeyedEncoder
        return encoder.container(keyedBy: NestedKey.self)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let encoder = superEncoder() as! KeyedEncoder
        return encoder.unkeyedContainer()
    }

    func superEncoder() -> Encoder {
        let encoder = cache.superEncoder(for: [AnyKey.superKey])

        return KeyedEncoder(encoder: encoder, codingPath: codingPath + [AnyKey.superKey]) { [cache] in
            return cache.node(for: [AnyKey.superKey]) // TODO check with superEncoder for: keyPatch
        }
    }

    func superEncoder(forKey key: K) -> Encoder {
        if key.isFlat {
            return keyedEncoder
        } else if key.isFirstFlat {
            let encoder = cache.superEncoder(for: Array(key.keyed.dropFirst()))
            let nodeKey = keyPath(forKey: key)
            return KeyedEncoder(encoder: encoder, codingPath: codingPath + [key]) { [cache] in
                return cache.node(for: nodeKey)
            }
        } else {
            let encoder = cache.superEncoder(for: keyPath(forKey: key))
            let nodeKey = keyPath(forKey: key)
            return KeyedEncoder(encoder: encoder, codingPath: codingPath + [key]) { [cache] in
                return cache.node(for: nodeKey)
            }
        }
    }
}

final class KeyedEncodingContainerCache {
    private(set) lazy var container: KeyedEncodingContainer<AnyKey> = {
        return self.encoder.container(keyedBy: AnyKey.self)
    }()

    private(set) var encoder: Encoder

    private(set) var dictionary: [AnyKey: KeyedEncodingContainerCache] = [:]

    //    private(set) var encoder: Encoder
    //    init(encoder: Encoder) {
    //        self.encoder = encoder
    //    }

    var _codingPath: [CodingKey] { return encoder.codingPath }

    init(encoder: Encoder) {
        self.encoder = encoder
    }

    func node(for keyPath: [AnyKey]) -> KeyedEncodingContainerCache {
        if keyPath.isEmpty {
            return self
        }
        var keyPath = keyPath
        let key = keyPath.removeFirst()

        return node(for: key).node(for: keyPath)
    }

    private func node(for key: AnyKey) -> KeyedEncodingContainerCache {
        if let cached = dictionary[key] {
            return cached
        }

        //print(self.container.codingPath)
        let encoder = container.superEncoder(forKey: key)
        let node = KeyedEncodingContainerCache(encoder: encoder)
        dictionary[key] = node
        return node
    }


    //=========
    private func keyWithPath(for keyPath: [AnyKey]) -> ([AnyKey], AnyKey) {
        //guard keyPath.count > 0 else { fatalError("shouldne be like that")}
        var keyPath = keyPath
        let key = keyPath.removeLast()
        return (keyPath, key)
    }
    func encodeNil(for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encodeNil(forKey: kP.1)
    }

    func encode(_ value: Bool, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: String, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: Double, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: Float, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: Int, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: Int8, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: Int16, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: Int32, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: Int64, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: UInt, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: UInt8, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: UInt16, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: UInt32, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func encode(_ value: UInt64, for keyPath: [AnyKey]) throws {
        let kP = keyWithPath(for: keyPath)
        return try node(for: kP.0).container.encode(value, forKey: kP.1)
    }

    func superEncoder(for keyPath: [AnyKey]) -> Encoder {
        let kP = keyWithPath(for: keyPath)
        return node(for: kP.0).container.superEncoder(forKey: kP.1)
    }
}
