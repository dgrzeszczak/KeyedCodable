//
//  AnyKey.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public struct AnyKey: CodingKey, Hashable {
    public let stringValue: String
    public let intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }

    public init(key: CodingKey) {
        if let intValue = key.intValue { self.init(intValue: intValue) }
        else { self.init(stringValue: key.stringValue )}
    }
}
//extension RandomAccessCollection where Element == CodingKey {
//    var keyed: [_Key] {
//        return map { key -> [_Key] in
//                if let key = key as? _Key {
//                    return [key]
//                } else {
//                    return key.keyed
//                }
//            }
//            .flatMap { $0 }
//    }
//}
