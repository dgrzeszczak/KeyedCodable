//
//  Helpers.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

struct EmptyCodable: Codable {}

extension RandomAccessCollection where Element == CodingKey {
    var codePathString: String {
        return self.map { "." + $0.stringValue }.joined()
    }
}

protocol _Optional {
    var hasValue: Bool { get }
    var value: Encodable? { get }
}

extension Optional: _Optional {
    var hasValue: Bool {
        if case .none = self {
            return false
        }
        return true
    }

    var value: Encodable? {
        if case .some(let value) = self, let encodable = value as? Encodable {
            return encodable
        }
        return nil
    }
}
