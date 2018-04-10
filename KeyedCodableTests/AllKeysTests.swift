//
//  AllKeysTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 09/04/2018.
//

@testable import KeyedCodable
import XCTest

import Foundation

public struct PaymentMethod: Decodable, Keyedable {

    private(set) public var type: String!
    private(set) public var isDefault: Bool!

    enum CodingKeys: String, CodingKey {
        case type
        case isDefault = "_attributes.default"
    }

    public mutating func map(map: KeyMap) throws {
        try type <<- map[CodingKeys.type]
        try isDefault <<- map[CodingKeys.isDefault]
    }

    public init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
public struct PaymentMethods: Decodable, Keyedable {

    private(set) public var userPaymentMethods: [PaymentMethod] = []
    private(set) public var autoTopUpToken: String?

    enum CodingKeys: String, CodingKey {
        case autoTopUpToken = "vault.autoTopup"
        case vault
    }

    public mutating func map(map: KeyMap) throws {
        try autoTopUpToken <<- map[CodingKeys.autoTopUpToken]
        guard case .decoding(let container) = map.type else { return }

        try container.allKeys(for: CodingKeys.vault).forEach { key in
            var paymentMethod: PaymentMethod?
            try paymentMethod <<- map[key]
            if let paymentMethod = paymentMethod {
                userPaymentMethods.append(paymentMethod)
            }
        }
    }

    public init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}

class AllKeysTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAllKeys() {
        let jsonData = jsonString.data(using: .utf8)

        let test = try! JSONDecoder().decode(PaymentMethods.self, from: jsonData!) // swiftlint:disable:this force_try

        XCTAssert(test.userPaymentMethods.count == 3)
    }
}

private let jsonString = """
{
    "vault": {
        "0": {
            "type": "Braintree_CreditCard",
            "_attributes": {
                "default": false
            }
        },
        "1": {
            "type": "Braintree_CreditCard",
            "_attributes": {
                "default": true
            }
        },
        "2": {
            "type": "Braintree_PayPalAccount",
            "_attributes": {
                "default": false
            }
        },
        "autoTopup": "9969dc"
    }
}
"""
