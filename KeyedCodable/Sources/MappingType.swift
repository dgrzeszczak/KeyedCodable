//
//  MappingType.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 11/05/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public enum MappingType {
    case decoding(keys: KeysCollection)
    case encoding

    public var isDecoding: Bool {
        guard case .decoding = self else { return false }
        return true
    }
}

public protocol KeysCollection {
    var all: [Key] { get }
    func all(for keyCode: CodingKey) -> [Key]
    func all(for keyCode: CodingKey, options: KeyOptions) -> [Key]
}

public extension KeysCollection {
    var all: [Key] {
        //guard let key =  else { fatalError("Unable to initialize flat Key") }
        return all(for: Key(stringValue: ""), options: KeyOptions())
    }

    func all(for keyCode: CodingKey) -> [Key] {
        return all(for: keyCode, options: KeyOptions())
    }
}
