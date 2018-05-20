//
//  KeyedEncoder.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

public final class KeyedEncoder {

    private let keyMap: KeyMap
    public init(with encoder: Encoder) {
        keyMap = KeyMap(keyMap: EncoderKeyMap(with: encoder))
    }

    public func encode<Type>(from object: Type) throws where Type: Encodable, Type: Keyedable {
        var object = object
        try object.map(map: keyMap)
    }
}

private final class EncoderKeyMap: KeyMapBase {
    private let startingCodePath: [CodingKey]
    private var containerDictionary: [String: KeyedEncodingContainer<Key>] = [:]
    private var container: KeyedEncodingContainer<Key>
    private let encoder: Encoder

    var type: MappingType { return .encoding }

    var userInfo: [CodingUserInfoKey: Any] {
        return encoder.userInfo
    }

    init(with encoder: Encoder) {
        self.encoder = encoder
        container = encoder.container(keyedBy: Key.self)
        startingCodePath = container.codingPath
        containerDictionary[startingCodePath.codePathString] = container
    }

    func encode<V>(object: V, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        if let flat = options.flat, flat == keyCode.stringValue {
            if let optional = object as? _Optional {
                if let value = optional.value {
                    try value.encode(to: encoder)
                }
            } else {
                try object.encode(to: encoder)
            }
        } else {
            var result = keyedEncodingContainer(for: keyCode, options: options)
            if let optional = object as? _Optional {
                if optional.hasValue {
                    try result.container.encode(object, forKey: result.key)
                }
            } else {
                try result.container.encode(object, forKey: result.key)
            }
        }
    }

    func encode<V>(object: V!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        if let flat = options.flat, flat == keyCode.stringValue {
            try object.encode(to: encoder)
        } else {
            var result = keyedEncodingContainer(for: keyCode, options: options)
            try result.container.encode(object, forKey: result.key)
        }
    }

    func encode<V>(object: [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        var result = keyedEncodingContainer(for: keyCode, options: options)

        if  let optionalArrayElements = options.optionalArrayElements,
            !optionalArrayElements.isEmpty,
            result.key.stringValue.starts(with: optionalArrayElements) {
            let key = Key(stringValue: String(result.key.stringValue.dropFirst(optionalArrayElements.count))) // "optional" array

            var unkeyedContainer = result.container.nestedUnkeyedContainer(forKey: key)
            try object.forEach {
                try unkeyedContainer.encode($0)
            }
        } else {
            if let optional = object as? _Optional {
                if optional.hasValue {
                    try result.container.encode(object, forKey: result.key)
                }
            } else {
                try result.container.encode(object, forKey: result.key)
            }
        }
    }

    func encode<V>(object: [V]!, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        var result = keyedEncodingContainer(for: keyCode, options: options)

        if  let optionalArrayElements = options.optionalArrayElements,
            !optionalArrayElements.isEmpty,
            result.key.stringValue.starts(with: optionalArrayElements) {
            let key = Key(stringValue: String(result.key.stringValue.dropFirst(optionalArrayElements.count))) // "optional" array

            var unkeyedContainer = result.container.nestedUnkeyedContainer(forKey: key)
            try object.forEach {
                try unkeyedContainer.encode($0)
            }
        } else {
            try result.container.encode(object, forKey: result.key)
        }
    }

    private func keyedEncodingContainer(for keyCode: CodingKey, options: KeyOptions) -> (container: KeyedEncodingContainer<Key>, key: Key) {
        var keys = keyCode.stringValue
            .components(separatedBy: options.delimiter ?? "")
            .compactMap { Key(stringValue: $0) }
        guard !keys.isEmpty else { fatalError("encode failed - no key") }

        var codingPath = startingCodePath
        // initialize containers
        while keys.count != 1 {
            codingPath.append(keys[0])
            keys.remove(at: 0)
            _ = keyedEncodingContainer(for: codingPath)
        }

        return (keyedEncodingContainer(for: codingPath), keys[0])
    }

    private func keyedEncodingContainer(for codingPath: [CodingKey]) -> KeyedEncodingContainer<Key> {
        let codePathString = codingPath.codePathString
        if let cached = containerDictionary[codePathString] {
            return cached
        }

        let parentCodePathString = codingPath.dropLast().codePathString

        guard var parent = containerDictionary[parentCodePathString] else {
            fatalError("KeyedEncoder - no parent container")
        }
        guard let lastKey = codingPath[codingPath.count - 1] as? Key else {
            fatalError("KeyedEncoder -  invalid key")
        }

        let container = parent.nestedContainer(keyedBy: Key.self, forKey: lastKey)
        containerDictionary[codePathString] = container
        return container
    }
}
