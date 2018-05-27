//
//  KeyedDecoder.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public final class KeyedDecoder {

    private let keyMap: KeyMap
    public init(with decoder: Decoder) throws {
        keyMap = try KeyMap(keyMap: DecoderKeyMap(with: decoder))
    }

    public func decode<Type>(to object: inout Type) throws where Type: Decodable, Type: Keyedable {
        try object.map(map: keyMap)
    }

    public func decode<Type>(to object: Type) throws where Type: Decodable, Type: Keyedable, Type: AnyObject{
        var object = object
        try object.map(map: keyMap)
    }
}

private final class DecoderKeyMap: KeyMapBase {

    var type: MappingType { return .decoding(keys: self) }

    private let startingCodePath: [CodingKey]
    private let container: KeyedDecodingContainer<Key>
    private var containerDictionary: [String: KeyedDecodingContainer<Key>] = [:]
    private let decoder: Decoder

    init(with decoder: Decoder) throws {
        self.decoder = decoder
        container = try decoder.container(keyedBy: Key.self)
        startingCodePath = container.codingPath
        containerDictionary[startingCodePath.codePathString] = container
    }

    var userInfo: [CodingUserInfoKey: Any] {
        return decoder.userInfo
    }

    func decode<V>(object: inout V, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        if let flat = options.flat, flat == keyCode.stringValue {
            if object is _Optional {
                try? object = V(from: decoder)
            } else {
                try object = V(from: decoder)
            }
        } else {
            let result = try keyedDecodingContainer(for: keyCode, options: options)
            if object is _Optional {
                if let val = try result.container.decodeIfPresent(V.self, forKey: result.key) {
                    object = val
                }
            } else {
                let val = try result.container.decode(V.self, forKey: result.key)
                object = val
            }
        }
    }

    func decode<V>(object: inout V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        if let flat = options.flat, flat == keyCode.stringValue {
            try object = V(from: decoder)
        } else {
            let result = try keyedDecodingContainer(for: keyCode, options: options)
            let val = try result.container.decode(V.self, forKey: result.key)
            object = val
        }
    }

    func decode<V>(object: inout [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        let result = try keyedDecodingContainer(for: keyCode, options: options)
        if  let optionalArrayElements = options.optionalArrayElements,
            !optionalArrayElements.isEmpty,
            result.key.stringValue.starts(with: optionalArrayElements) {
            let key = Key(stringValue: String(result.key.stringValue.dropFirst(optionalArrayElements.count))) // "optional" array

            var unkeyedContainer = try result.container.nestedUnkeyedContainer(forKey: key)
            var newObject = [V]()
            while !unkeyedContainer.isAtEnd {
                if let route = try? unkeyedContainer.decode(V.self) {
                    newObject.append(route)
                } else {
                    _ = try? unkeyedContainer.decode(EmptyCodable.self)
                }
            }
            object = newObject
        } else {
            if object is _Optional {
                if let val = try result.container.decodeIfPresent([V].self, forKey: result.key) {
                    object = val
                }
            } else {
                let val = try result.container.decode([V].self, forKey: result.key)
                object = val
            }
        }
    }

    func decode<V>(object: inout [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        let result = try keyedDecodingContainer(for: keyCode, options: options)
        if  let optionalArrayElements = options.optionalArrayElements,
            !optionalArrayElements.isEmpty,
            result.key.stringValue.starts(with: optionalArrayElements) {
            let key = Key(stringValue: String(result.key.stringValue.dropFirst(optionalArrayElements.count))) // "optional" array

            var unkeyedContainer = try result.container.nestedUnkeyedContainer(forKey: key)
            var newObject = [V]()
            while !unkeyedContainer.isAtEnd {
                if let route = try? unkeyedContainer.decode(V.self) {
                    newObject.append(route)
                } else {
                    _ = try? unkeyedContainer.decode(EmptyCodable.self)
                }
            }
            object = newObject
        } else {
            let val = try result.container.decode([V].self, forKey: result.key)
            object = val
        }
    }

    private func keyedDecodingContainer(for keyCode: CodingKey, options: KeyOptions) throws -> (container: KeyedDecodingContainer<Key>, key: Key) {
        var keys = keyCode.stringValue
            .components(separatedBy: options.delimiter ?? "")
            .compactMap { Key(stringValue: $0) }
        guard !keys.isEmpty else { fatalError("encode failed - no key") }

        var codingPath = startingCodePath
        // initialize containers
        while keys.count != 1 {
            codingPath.append(keys[0])
            keys.remove(at: 0)
            _ = try keyedDecodingContainer(for: codingPath)
        }

        return (try keyedDecodingContainer(for: codingPath), keys[0])
    }

    private func keyedDecodingContainer(for codingPath: [CodingKey]) throws -> KeyedDecodingContainer<Key> {
        let codePathString = codingPath.codePathString
        if let cached = containerDictionary[codePathString] {
            return cached
        }

        let parentCodePathString = codingPath.dropLast().codePathString
        guard let parent = containerDictionary[parentCodePathString] else {
            fatalError("KeyedDecoder - no parent container")
        }
        guard let lastKey = codingPath[codingPath.count - 1] as? Key else {
            fatalError("KeyedDecoder - invalid key")
        }

        let container = try parent.nestedContainer(keyedBy: Key.self, forKey: lastKey)
        containerDictionary[codePathString] = container
        return container
    }
}

extension DecoderKeyMap: KeysCollection {
    func all(for keyCode: CodingKey, options: KeyOptions) -> [Key] {
        if let flat = options.flat, flat == keyCode.stringValue {
            return container.allKeys
        } else {
            guard let result = try? keyedDecodingContainer(for: keyCode, options: options) else { return [] }
            guard let container = try? result.container.nestedContainer(keyedBy: Key.self, forKey: result.key) else { return [] }
            return container.allKeys.compactMap {
                Key(stringValue: keyCode.stringValue + (options.delimiter ?? "") + $0.stringValue)
            }
        }
    }
}
