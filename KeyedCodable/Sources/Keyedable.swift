//
//  Keyedable.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

// TODO transformers?

public protocol Keyedable {

    mutating func map(map: KeyMap) throws
}

public extension Keyedable where Self: Encodable {
    func encode(to encoder: Encoder) throws {
        try KeyedEncoder(with: encoder).encode(from: self)
    }
}
