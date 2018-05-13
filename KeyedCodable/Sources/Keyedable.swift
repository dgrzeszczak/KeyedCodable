//
//  Keyedable.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

// TODO transformers?

public protocol Keyedable {
    associatedtype CodingKeys: CodingKey

    typealias KeyMap = Map<CodingKeys>
    mutating func map(map: KeyMap) throws
}

public extension Keyedable where Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        try KeyedEncoder(with: encoder).encode(from: self)
    }
}
