//
//  AllKeysTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 09/04/2018.
//

@testable import KeyedCodable
import XCTest

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

struct PaymentMethod: Decodable, Keyedable {

    private(set) public var type: String!
    private(set) public var isDefault: Bool!

    public enum CodingKeys: String, CodingKey {
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

struct PaymentMethods: Decodable, Keyedable {

    private(set) var userPaymentMethods: [PaymentMethod] = []
    private(set) var autoTopUpToken: String?

    enum CodingKeys: String, CodingKey {
        case autoTopUpToken = "vault.autoTopup"
        case vault
    }

    mutating func map(map: KeyMap) throws {
        try autoTopUpToken <<- map[CodingKeys.autoTopUpToken]
        guard case .decoding(let keys) = map.type else { return }

        keys.all(for: CodingKeys.vault).forEach { key in
            var paymentMethod: PaymentMethod?
            try? paymentMethod <<- map[key]
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
        let jsonData = jsonString.data(using: .utf8)!

        var test: PaymentMethods!
        do {
            test = try JSONDecoder().decode(PaymentMethods.self, from: jsonData)
        } catch ( let error ) {
            XCTFail("PaymentMethods cannot be parsed")
            print(error.localizedDescription)
            return
        }

        XCTAssert(test.userPaymentMethods.count == 3)
        XCTAssert(test.userPaymentMethods[1].type == "Braintree_CreditCard")
        XCTAssert(test.userPaymentMethods[1].isDefault == true)
    }
}
