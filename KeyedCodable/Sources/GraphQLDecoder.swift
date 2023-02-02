//
//  GraphQLDecoder.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 08/11/2021.
//

import Foundation

open class GraphQLDecoder {

    public init() {

    }

    open func build<T : Decodable>(_ type: T.Type, jsonDecoder: JSONDecoder = KeyedJSONDecoder()) throws -> Graph {

        let decoder = GraphDecoder(userInfo: [:])
        _ = try Keyed<T>.init(from: decoder)
        return decoder.graph
    }
}


//extension Graph: Decodable where Base: Decodable {
//    public init(from decoder: Decoder) throws {
//        if let graphDecoder = decoder as? GraphDecoder {
//            value = try graphDecoder.singleValueContainer().decode(Base.self)
//        } else {
//            let decoder = GraphDecoder(decoder: decoder, codingPath: decoder.codingPath)
//            self.decoder = decoder
//            value = try Base(from: decoder)
//        }
//    }
//}

struct Node {
    let type: Any.Type?
    let children: [String: Node]
    let value: String

    init(children: [String: Node] = [:], type: Any.Type? = nil, value: String) {
        self.children = children
        self.type = type
        self.value = value
    }

//    mutating func add(path: [String], type: Any.Type) {
//
//    }

    func updating(path: [String], type: Any.Type?, value: String?) -> Node {


        if let first = path.first {
            let path = Array(path.dropFirst())

            if children.isEmpty {
                return Node(children: [first: Node(value: first).updating(path: path, type: type, value: value)],
                            type: self.type,
                            value: self.value)
            } else {
                var children = self.children
                children[first] = (children[first] ?? Node(value: first)).updating(path: path, type: type, value: value)
                return Node(children: children,
                            type: self.type,
                            value: self.value)
            }
        } else {
            return Node(children: children,
                        type: type ?? self.type,
                        value: value ?? self.value)
        }
    }

    func toString(pretty: Bool = true, level: Int = 1) -> String {
        let newLine = "\n"
        let tab = "  "
        let closeIdent = Array(repeating: tab, count: level - 1).reduce("") { $0 + $1}
        let ident = closeIdent + tab

        var string = ""
        if !value.isEmpty {
            string += value + " "
        }

        guard !children.isEmpty else { return string }

        let childrenString = children.keys.map { "\(ident)\(children[$0]!.toString(pretty: pretty, level: level + 1))\(newLine)" }.reduce("") { $0 + $1 }

        return string + "{\(newLine)\(childrenString)\(closeIdent)}"

    }
}

public class Graph {

    var node = Node(value: "")

    func add(keyPath: [CodingKey], type: Any.Type) {
        node = node.updating(path: keyPath.compactMap { $0.intValue != nil ? nil : $0.stringValue },
                             type: type, value: nil)
    }

    public func updating(_ path: [String], value: String) -> Graph {
        let graph = Graph()
        graph.node = node.updating(path: path, type: nil, value: value)
        return  graph
    }

//    public func updating(_ path: [String], updateClosure: (Graph) ->  Graph) -> Graph {
//        let graph = Graph()
//        graph.node = node.updating(path: path, type: nil, value: value)
//        return  graph
//    }

    public func toString(pretty: Bool = true) -> String {
        node.toString(pretty: pretty)
    }



    func test() {

    }
}

class GraphDecoder: Decoder {

    enum Node {
        case root(userInfo: [CodingUserInfoKey : Any])
        case leaf(parent: GraphDecoder, key: CodingKey)

        var userInfo: [CodingUserInfoKey : Any] {
            switch self {
            case .root(let userInfo): return userInfo
            case .leaf(let parent, _): return parent.userInfo
            }
        }

        var codingPath: [CodingKey] {
            switch self {
            case .root: return []
            case .leaf(let parent, let key): return parent.codingPath + [key]
            }
        }

        var parent: GraphDecoder? {
            switch self {
            case .root: return nil
            case .leaf(let parent,_): return parent
            }
        }
    }

    let node: Node

    let codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any] { node.userInfo }

    init(userInfo: [CodingUserInfoKey : Any]) {
        var userInfo = userInfo
        userInfo[CodingUserInfoKey(rawValue: "dupa")!] = Graph()
        node = .root(userInfo: userInfo)
        codingPath = []
    }

    init(parent: GraphDecoder, key: CodingKey) {
        node = .leaf(parent: parent, key: key)
        codingPath = node.codingPath
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return try KeyedDecodingContainer(GraphKeyedDecodingContainer(graphDecoder: self))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try GraphUnkeyedDecodingContainer(graphDecoder: self)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return try GraphSingleValueDecodingContainer(graphDecoder: self)
    }

    var graph: Graph {
        userInfo[CodingUserInfoKey(rawValue: "dupa")!] as! Graph
    }
}


struct GraphSingleValueDecodingContainer: SingleValueDecodingContainer {

    private let graphDecoder: GraphDecoder

    var codingPath: [CodingKey] { return graphDecoder.codingPath }

    init(graphDecoder: GraphDecoder) throws {
        self.graphDecoder = graphDecoder
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        graphDecoder.graph.add(keyPath: codingPath, type: Bool.self)
        return false
    }

    func decode(_ type: String.Type) throws -> String {
        graphDecoder.graph.add(keyPath: codingPath, type: String.self)
        return ""
    }

    func decode(_ type: Double.Type) throws -> Double {
        graphDecoder.graph.add(keyPath: codingPath, type: Double.self)
        return 0
    }

    func decode(_ type: Float.Type) throws -> Float {
        graphDecoder.graph.add(keyPath: codingPath, type: Float.self)
        return 0
    }

    func decode(_ type: Int.Type) throws -> Int {
        graphDecoder.graph.add(keyPath: codingPath, type: Int.self)
        return 0
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        graphDecoder.graph.add(keyPath: codingPath, type: Int8.self)
        return 0
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        graphDecoder.graph.add(keyPath: codingPath, type: Int16.self)
        return 0
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        graphDecoder.graph.add(keyPath: codingPath, type: Int32.self)
        return 0
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        graphDecoder.graph.add(keyPath: codingPath, type: Int64.self)
        return 0
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        graphDecoder.graph.add(keyPath: codingPath, type: UInt.self)
        return 0
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        graphDecoder.graph.add(keyPath: codingPath, type: UInt8.self)
        return 0
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        graphDecoder.graph.add(keyPath: codingPath, type: UInt16.self)
        return 0
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        graphDecoder.graph.add(keyPath: codingPath, type: UInt32.self)
        return 0
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        graphDecoder.graph.add(keyPath: codingPath, type: UInt64.self)
        return 0
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T(from: graphDecoder)
    }
}

class GraphUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    private let graphDecoder: GraphDecoder

    init(graphDecoder: GraphDecoder) throws {
        self.graphDecoder = graphDecoder
    }

    var codingPath: [CodingKey] { return graphDecoder.codingPath }

    private(set) var currentIndex: Int = 0
    var count: Int? { 1 }

    var isAtEnd: Bool { currentIndex >= count ?? 0  }

    func decodeNil() throws -> Bool { false }

    func decode(_ type: Bool.Type) throws -> Bool {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: String.Type) throws -> String {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: Double.Type) throws -> Double {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: Float.Type) throws -> Float {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: Int.Type) throws -> Int {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try superDecoder().singleValueContainer().decode(type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try superDecoder().singleValueContainer().decode(type)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try KeyedDecodingContainer(GraphKeyedDecodingContainer<NestedKey>(graphDecoder: superDecoder() as! GraphDecoder))
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try GraphUnkeyedDecodingContainer(graphDecoder: superDecoder() as! GraphDecoder)
    }

    func superDecoder() throws -> Decoder {
        let decoder = GraphDecoder(parent: graphDecoder, key: AnyKey(intValue: currentIndex))
        currentIndex += 1
        return decoder
    }
}

final class GraphKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {

    private let graphDecoder: GraphDecoder

    init(graphDecoder: GraphDecoder) throws {
        self.graphDecoder = graphDecoder
    }

    var codingPath: [CodingKey] { return graphDecoder.codingPath }

    var allKeys: [K] {
        guard let type = K.self as? CaseIterableKey.Type else { return [] }
        return type.allKeys.compactMap { K(stringValue: $0.stringValue) }.filter(contains)
    }

    func contains(_ key: K) -> Bool {
        return true
    }

    func decodeNil(forKey key: K) throws -> Bool {
        try superDecoder(forKey: key).singleValueContainer().decodeNil()
    }

    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: String.Type, forKey key: K) throws -> String {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }


    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        try superDecoder(forKey: key).singleValueContainer().decode(type)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let decoder = try superDecoder(forKey: key)
        return try KeyedDecodingContainer(GraphKeyedDecodingContainer<NestedKey>(graphDecoder: decoder as! GraphDecoder))
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        let decoder = try superDecoder(forKey: key)
        return try GraphUnkeyedDecodingContainer(graphDecoder: decoder as! GraphDecoder)
    }

    func superDecoder() throws -> Decoder {
        return GraphDecoder(parent: graphDecoder, key: AnyKey.superKey)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        return GraphDecoder(parent: graphDecoder, key: key)
    }
}
