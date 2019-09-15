////
////  Helpers.swift
////  KeyedCodable
////
////  Created by Dariusz Grzeszczak on 26/03/2018.
////  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
////
//

extension AnyKey {
    static var superKey: AnyKey { return AnyKey(stringValue: "super") }
}

extension CodingKey {

    init?(_ key: AnyKey) {
        if let intValue = key.intValue, let zelf = Self(intValue: intValue) {
            self = zelf
        } else if let zelf = Self(stringValue: key.stringValue) {
            self = zelf
        } else {
            return nil
        }
    }

    var isFlat: Bool {
        guard let key = self as? AnyKeyedKey else { return false }
        return (key.options?.flat ?? KeyedConfig.default.keyOptions.flat).isFlat(key: key)
    }

    var isFirstFlat: Bool {
        guard let key = self as? AnyKeyedKey else { return false }
        let keyed = key.keyed
        guard keyed.count > 1 else { return false }
        return (key.options?.flat ?? KeyedConfig.default.keyOptions.flat).isFlat(key: keyed[0])
    }

    var keyed: [AnyKey] {
        guard let key = self as? AnyKeyedKey else { return [AnyKey(key: self)] }
        guard case .character(let character) = key.options?.delimiter ?? KeyedConfig.default.keyOptions.delimiter else { return [AnyKey(key: key)] }

        return stringValue //TODO: indexes ??
            .components(separatedBy: String(character))
            .compactMap(AnyKey.init)
    }
}

protocol _Array {
    static func optionalDecode<T>(unkeyedContainer: UnkeyedDecodingContainer) -> T
}

extension Array: _Array where Element: Decodable {
    static func optionalDecode<T>(unkeyedContainer: UnkeyedDecodingContainer) -> T {
        var unkeyedContainer = unkeyedContainer
        var newObject = [Element]()
        while !unkeyedContainer.isAtEnd {
            if let value = try? unkeyedContainer.decode(Element.self) {
                newObject.append(value)
            }
            //      swift 4 ?
            //            else {
            //                _ = try? unkeyedContainer.decode(EmptyCodable.self)
            //            }
        }
        return newObject as! T
    }
}

extension Data {
    static func from(string: String, encoding: String.Encoding = .utf8) throws -> Data {
        guard let data = string.data(using: encoding) else { throw KeyedCodableError.stringParseFailed }
        return data
    }
}

extension String {
     static func from(data: Data, encoding: String.Encoding = .utf8) throws -> String {
        guard let string = String(data: data, encoding: encoding) else { throw KeyedCodableError.stringParseFailed }
        return string
    }
}
