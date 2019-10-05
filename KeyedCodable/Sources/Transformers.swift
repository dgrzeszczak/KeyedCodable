//
//  Transformers.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 05/10/2019.
//

import Foundation

#if swift(>=5.1)
public protocol DecodableTransformer {
    associatedtype Source: Decodable
    associatedtype Object

    static func transform(from decodable: Source) throws -> Any?
}

public protocol EncodableTransformer {
    associatedtype Destination: Encodable
    associatedtype Object

    static func transform(object: Object) throws -> Destination?
}

public protocol Transformer: DecodableTransformer, EncodableTransformer where Source == Destination { }


@propertyWrapper
public struct EncodedBy<T: EncodableTransformer>: Encodable {
    public var wrappedValue: T.Object

    public init(wrappedValue: T.Object) {
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: Encoder) throws {
        try encodeObject(object: wrappedValue, transType: T.self, encoder: encoder)
    }
}

@propertyWrapper
public struct DecodedBy<T: DecodableTransformer>: Decodable {
    public var wrappedValue: T.Object

    public init(wrappedValue: T.Object) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        wrappedValue = try decodeObject(transType: T.self, decoder: decoder)
    }
}

@propertyWrapper
public struct CodedBy<T: Transformer>: Codable {
    public var wrappedValue: T.Object

    public init(wrappedValue: T.Object) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        wrappedValue = try decodeObject(transType: T.self, decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try encodeObject(object: wrappedValue, transType: T.self, encoder: encoder)
    }
}

private func encodeObject<T>(object: T.Object, transType: T.Type, encoder: Encoder)
    throws where T: EncodableTransformer {
        let encodable = try T.transform(object: object)
        var container = encoder.singleValueContainer()
        try container.encode(encodable)
}

private func decodeObject<T>(transType: T.Type, decoder: Decoder)
    throws -> T.Object where T: DecodableTransformer{

    let source: T.Source

    if let type = T.Object.self as? _Optional.Type, !(T.Source.self is _Optional.Type) {
        guard let s = try Optional<T.Source>(from: decoder) else {
            return type.empty as! T.Object
        }

        source = s
    } else {
        source = try T.Source(from: decoder)
    }

    guard let value = try T.transform(from: source) as? T.Object else {
        throw KeyedCodableError.transformFailed
    }
    return value
}

extension EncodedBy: Nullable {
    var isNil: Bool {
        guard let wrapped = wrappedValue as? _Optional else { return false }
        return wrapped.isNil
    }
}
extension CodedBy: Nullable {
    var isNil: Bool {
        guard let wrapped = wrappedValue as? _Optional else { return false }
        return wrapped.isNil
    }
}

protocol Nullable {
    var isNil: Bool { get }
}

protocol _Optional: Nullable {
    static var empty: _Optional { get }
}

extension Optional: _Optional {
    static var empty: _Optional {
        return self.none
    }

    var isNil: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
}
#endif
