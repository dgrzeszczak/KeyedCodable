//
//  AnyKey.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public struct AnyKey: CodingKey, Hashable, AnyKeyedKey {

    public let stringValue: String
    public let intValue: Int?

    public let options: KeyOptions?

    public init(stringValue: String, options: KeyOptions) {
        self.stringValue = stringValue
        intValue = nil
        self.options = options
    }

    public init(intValue: Int, options: KeyOptions) {
        stringValue = String(intValue)
        self.intValue = intValue
        self.options = options
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
        options = nil
    }

    public init(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
        options = nil
    }

    public init(key: CodingKey, options: KeyOptions? = nil) {
        if let intValue = key.intValue { self.init(intValue: intValue) }
        else { self.init(stringValue: key.stringValue )}
    }
}
