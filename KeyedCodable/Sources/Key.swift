//
//  Key.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

public struct Key: CodingKey {
    public let stringValue: String

    public init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public let intValue: Int?

    public init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}
