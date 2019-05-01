//
//  AllKeysTests.swift
//  KeyedCodableTests
//
//  Created by Dariusz Grzeszczak on 09/04/2018.
//

import KeyedCodable
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

struct PaymentMethod: Decodable {

    let type: String
    let isDefault: Bool

    public enum CodingKeys: String, KeyedKey {
        case type
        case isDefault = "_attributes.default"
    }
}

struct PaymentMethods: Decodable {

    let userPaymentMethods: [PaymentMethod]
    let autoTopUpToken: String?

    enum CodingKeys: String, KeyedKey {
        case autoTopUpToken = "vault.autoTopup"
        case vault
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        autoTopUpToken = try container.decode(String.self, forKey: .autoTopUpToken)

        let universalContainer = try container.nestedContainer(keyedBy: AnyKey.self, forKey: .vault)
        userPaymentMethods = universalContainer.allKeys
            .sorted { $0.stringValue < $1.stringValue }
            .compactMap { try? universalContainer.decode(PaymentMethod.self, forKey: $0) }
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
            test = try KeyedJSONDecoder().decode(PaymentMethods.self, from: jsonData)
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
