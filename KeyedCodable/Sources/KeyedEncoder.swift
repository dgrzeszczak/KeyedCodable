//
//  KeyedEncoder.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

public final class KeyedEncoder {

    private let encoder: Encoder
    public init(with encoder: Encoder) {
        self.encoder = encoder
    }

    public func encode<Type>(from object: Type) throws where Type: Encodable, Type: Keyedable {
        let encoder = EncoderKeyMap(with: self.encoder)
        let keyMap = KeyMap(keyMap: encoder)
        var object = object
        try object.map(map: keyMap)
        try encoder.encode()
    }
}

private enum Encoding {
    case container(KeyedEncodingContainer<Key>, key: Key)
    case encoder(Encoder)
}

private class Node {

    let key: String?

    var root: [(_ encoding: Encoding) throws -> Void] = []
    var children: [String: Node] = [:]

    init(key: String?) {
        self.key = key
    }

    func node(for key: String, options: KeyOptions) -> Node {
        var keys = key.components(separatedBy: options.delimiter ?? "")
        guard !keys.isEmpty else { fatalError("encode failed - no key") }

        var currentNode: Node = self

        while keys.count != 0 {
            let key = keys[0]
            if let node = currentNode.children[key] {
                currentNode = node
            } else {
                let node = Node(key: key)
                currentNode.children[key] = node
                currentNode = node
            }
            keys.remove(at: 0)
        }

        return currentNode
    }

    func encode(container: KeyedEncodingContainer<Key>) throws {
        var container = container
        guard let key = key else {
            try children.values.forEach {
                try $0.encode(container: container)
            }
            return
        }

        if children.keys.isEmpty {
            try root.forEach {
                try $0(.container(container, key: Key(stringValue: key)))
            }
        } else {
            var cont: KeyedEncodingContainer<Key>
            if root.isEmpty {
                cont = container.nestedContainer(keyedBy: Key.self, forKey: Key(stringValue: key))
            } else {
                let encoder = container.superEncoder(forKey: Key(stringValue: key))
                cont = encoder.container(keyedBy: Key.self)
                try root.forEach {
                    try $0(.encoder(encoder))
                }
            }

            try children.values.forEach {
                try $0.encode(container: cont)
            }
        }
    }
}

private final class EncoderKeyMap: KeyMapBase {
    private let startingCodePath: [CodingKey]
    private var containerDictionary: [String: KeyedEncodingContainer<Key>] = [:]
    private var container: KeyedEncodingContainer<Key>
    private let encoder: Encoder

    var node: Node

    var type: MappingType { return .encoding }

    var userInfo: [CodingUserInfoKey: Any] {
        return encoder.userInfo
    }

    init(with encoder: Encoder) {
        self.encoder = encoder
        container = encoder.container(keyedBy: Key.self)
        startingCodePath = container.codingPath
        containerDictionary[startingCodePath.codePathString] = container

        node = Node(key: nil)
    }

    func encode<V>(object: V, with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {

        if let flat = options.flat, flat == keyCode.stringValue {
            try EncoderKeyMap.encode(object: object, encoding: .encoder(encoder))
        } else {
            node.node(for: keyCode.stringValue, options: options).root.append( { encoding in
                try EncoderKeyMap.encode(object: object, encoding: encoding)
            })
        }
    }

    func encode() throws {
        try node.encode(container: container)
    }

    func encode<V>(object: [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Encodable {
        node.node(for: keyCode.stringValue, options: options).root.append( { encoding in

            if  case .container(let container, let key) = encoding,
                let optionalArrayElements = options.optionalArrayElements,
                !optionalArrayElements.isEmpty,
                key.stringValue.starts(with: optionalArrayElements) {
                let key = Key(stringValue: String(key.stringValue.dropFirst(optionalArrayElements.count))) // "optional" array

                try EncoderKeyMap.encode(object: object, encoding: .container(container, key: key))
            } else {
                try EncoderKeyMap.encode(object: object, encoding: encoding)
            }
        })
    }

    private static func encode<V>(object: V, encoding: Encoding) throws where V: Encodable {
        if let optional = object as? _Optional {
            if let value = optional.value {
                switch encoding {
                case .encoder(let encoder): try value.encode(to: encoder)
                case .container(var container, let key): try container.encode(object, forKey: key)
                }
            }
        } else {
            switch encoding {
            case .encoder(let encoder): try object.encode(to: encoder)
            case .container(var container, let key): try container.encode(object, forKey: key)
            }
        }
    }
}
