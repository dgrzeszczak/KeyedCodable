//
//  KeyedKey.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 01/05/2019.
//

import Foundation

public protocol KeyedKey: CaseIterable, CaseIterableKey, AnyKeyedKey { }

public protocol AnyKeyedKey: CodingKey {

    var options: KeyOptions? { get }
}

public protocol CaseIterableKey: CodingKey {

    static var allKeys: [CodingKey] { get }
}

extension KeyedKey {
    public static var allKeys: [CodingKey] {
        return Array(allCases)
    }

    public var options: KeyOptions? { return nil }
}

public struct KeyOptions: Hashable {
    public var flat: Flat
    public var delimiter: Delimiter

    public init(delimiter: Delimiter = KeyedConfig.default.keyOptions.delimiter,
                flat: Flat = KeyedConfig.default.keyOptions.flat) {
        self.flat = flat
        self.delimiter = delimiter
    }

    public enum Delimiter: Hashable {
        case none
        case character(_ character: Character)
    }

    public enum Flat: Hashable {
        case none
        case emptyOrWhitespace
        case string(_ string: String)

        public func isFlat(key: CodingKey) -> Bool {
            switch self {
            case .none: return false
            case .emptyOrWhitespace: return key.intValue == nil && key.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            case .string(let string): return key.stringValue == string
            }
        }
    }
}

#if swift(>=5.1)
@propertyWrapper
public struct Flat<T: Decodable>: Decodable {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        if let type = T.self as? _Array.Type {
            let unkeyed = try decoder.unkeyedContainer()
            wrappedValue = type.optionalDecode(unkeyedContainer: unkeyed)
        } else if let type = T.self as? _Optional.Type {
            guard let value = try? T(from: decoder) else {
                wrappedValue = type.empty as! T
                return
            }
            wrappedValue =  value
        } else {
            wrappedValue = try T(from: decoder)
        }
    }
}

extension Flat: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

protocol FlatType {
    static var isArray: Bool { get }
}
extension Flat: FlatType {
    static var isArray: Bool {
        return T.self is _Array.Type
    }
}
extension Flat: Nullable {
    var isNil: Bool {
        guard let wrapped = wrappedValue as? _Optional else { return false }
        return wrapped.isNil
    }
}
#endif

public struct Keyed<Base> {

    @available(*, deprecated, renamed: "Base")
    typealias Value = Base

    public let value: Base

    public init(_ value: Base) {
        self.value = value
    }
}

public enum KeyedCodableError: Error {
    case stringParseFailed
    case transformFailed
}
