//
//  KeyMap.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

import Foundation

public enum MappingType {
    case decoding(container: KeyedDecoderContainer)
    case encoding

    public var isDecoding: Bool {
        guard case .decoding = self else { return false }
        return true
    }
}

public protocol KeyedDecoderContainer {
    func allKeys(for keyCode: CodingKey) -> [Key]
    func allKeys(for keyCode: CodingKey, options: KeyOptions) -> [Key]
}

public extension KeyedDecoderContainer {
    func allKeys(for keyCode: CodingKey) -> [Key] {
        return allKeys(for: keyCode, options: KeyOptions())
    }
}

public protocol KeyMap {
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

extension KeyMap {

    public func decode<V>(object: inout V, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable { }
    public func decode<V>(object: inout V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable { }

    public func decode<V>(object: inout [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable { }
    public func decode<V>(object: inout [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable { }

    public func encode<V>(object: V, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable { }
    public func encode<V>(object: V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable { }

    public func encode<V>(object: [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable { }
    public func encode<V>(object: [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable { }
}

public extension KeyMap {
    public subscript(key: CodingKey) -> Mapping {
        return Mapping(map: self, key: key, options: KeyOptions())
    }

    public subscript(key: CodingKey, options: KeyOptions) -> Mapping {
        return Mapping(map: self, key: key, options: options)
    }
}

public struct Mapping {
    let map: KeyMap
    let key: CodingKey
    let options: KeyOptions
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

protocol _Optional {
    var hasValue: Bool { get }
    var value: Encodable? { get }
}

extension Optional: _Optional {//} where Wrapped: Codable {
    var hasValue: Bool {
        if case .none = self {
            return false
        }
        return true
    }

    var value: Encodable? {
        if case .some(let value) = self, let encodable = value as? Encodable {
            return encodable
        }
        return nil
    }
}
