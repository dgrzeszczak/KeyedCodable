//
//  Operators.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

infix operator <->

public func <-> <T, Key: CodingKey>(left: inout T, right: Mapping<Key>) throws where T: Codable {
    if right.map.type.isDecoding {
        try left <<- right
    } else {
        try left ->> right
    }
}

public func <-> <T, Key: CodingKey>(left: inout T!, right: Mapping<Key>) throws where T: Codable {
    if right.map.type.isDecoding {
        try left <<- right
    } else {
        try left! ->> right
    }
}

public func <-> <T, Key: CodingKey>(left: inout [T], right: Mapping<Key>) throws where T: Codable {
    if right.map.type.isDecoding {
        try left <<- right
    } else {
        try left ->> right
    }
}

public func <-> <T, Key: CodingKey>(left: inout [T]!, right: Mapping<Key>) throws where T: Codable {
    if right.map.type.isDecoding {
        try left <<- right
    } else {
        try left! ->> right
    }
}

infix operator <<-

public func <<- <T, Key: CodingKey>(left: inout T, right: Mapping<Key>) throws where T: Decodable {
    try right.map.decode(object: &left, with: right.key, options: right.options)
}

public func <<- <T, Key: CodingKey>(left: inout T!, right: Mapping<Key>) throws where T: Decodable {
    try right.map.decode(object: &left, with: right.key, options: right.options)
}

public func <<- <T, Key: CodingKey>(left: inout [T], right: Mapping<Key>) throws where T: Decodable {
    try right.map.decode(object: &left, with: right.key, options: right.options)
}

public func <<- <T, Key: CodingKey>(left: inout [T]!, right: Mapping<Key>) throws where T: Decodable {
    try right.map.decode(object: &left, with: right.key, options: right.options)
}

infix operator ->>

public func ->> <T, Key: CodingKey>(left: T, right: Mapping<Key>) throws where T: Encodable {
    try right.map.encode(object: left, with: right.key, options: right.options)
}

public func ->> <T, Key: CodingKey>(left: T!, right: Mapping<Key>) throws where T: Encodable {
    try right.map.encode(object: left!, with: right.key, options: right.options)
}

public func ->> <T, Key: CodingKey>(left: [T], right: Mapping<Key>) throws where T: Encodable {
    try right.map.encode(object: left, with: right.key, options: right.options)
}

public func ->> <T, Key: CodingKey>(left: [T]!, right: Mapping<Key>) throws where T: Encodable {
    try right.map.encode(object: left!, with: right.key, options: right.options)
}
