//
//  KeyedKey.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 01/05/2019.
//

import Foundation

public protocol KeyedKey: CaseIterable, AnyKeyedKey { }

public protocol AnyKeyedKey: CodingKey {
    static var allKeys: [CodingKey] { get }

    var options: KeyOptions? { get }
}

extension KeyedKey {
    public static var allKeys: [CodingKey] {
        return Array(allCases)
    }

    public var options: KeyOptions? { return nil }
}

public struct KeyOptions {
    public var flat: Flat
    public var delimiter: Delimiter

    public init(delimiter: Delimiter = KeyedConfig.default.keyOptions.delimiter,
                flat: Flat = KeyedConfig.default.keyOptions.flat) {
        self.flat = flat
        self.delimiter = delimiter
    }

    public enum Delimiter {
        case none
        case character(_ character: Character)
    }

    public enum Flat {
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
