//
//  Helpers.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

struct EmptyCodable: Codable {}

extension RandomAccessCollection where Element == CodingKey {
    var codePathString: String {
        return self.map { $0.stringValue }.joined()
    }
}
