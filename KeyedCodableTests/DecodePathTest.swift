//
//  DecodePathTest.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 25/07/2019.
//

import KeyedCodable
import XCTest

struct Token: Codable {

    static var keyPath: String = "data"
    static var key: AnyKey {
        return AnyKey(stringValue: keyPath)
    }

    public let accessToken: String
    public let expiresIn: Int
    public let refreshToken: String

    public enum CodingKeys: String, CodingKey {
        case accessToken = "access.token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"

        static var container = "data"
    }
}

struct TokenContainer: Codable {
    public private(set) var token: Token

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: AnyKey.self)
        token = try container.decode(Token.self, forKey: Token.key)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy:  AnyKey.self)
        try container.encodeIfPresent(token, forKey: Token.key)
    }
}

class DecodePathTests: XCTestCase {

    func testTokenMapping() {

        let innerDataTokenJSON = """
            {
                "data": {
                    "access.token": "access",
                    "expires_in": 2,
                    "refresh_token": "refresh"
                }
            }
            """.data(using: .utf8)!

        KeyedCodableTestHelper.checkEncode(data: innerDataTokenJSON, checkString: false) { (test: TokenContainer) in

            XCTAssert(test.token.accessToken == "access")
            XCTAssert(test.token.expiresIn == 2)
            XCTAssert(test.token.refreshToken == "refresh")
        }

        let tokenJSONString = """
            {
                "access.token": "access",
                "expires_in": 2,
                "refresh_token": "refresh"
            }
            """.data(using: .utf8)!

        Token.keyPath = ""

        KeyedCodableTestHelper.checkEncode(data: tokenJSONString, checkString: false) { (test: TokenContainer) in

            XCTAssert(test.token.accessToken == "access")
            XCTAssert(test.token.expiresIn == 2)
            XCTAssert(test.token.refreshToken == "refresh")
        }
    }

}
