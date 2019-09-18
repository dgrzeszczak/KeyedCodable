//
//  KeyedConfig.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public struct KeyedConfig {

    public static var `default` = KeyedConfig()

    public var keyOptions: KeyOptions
    public var defaultJSONDecoder: () -> KeyedJSONDecoder
    public var defaultJSONEncoder: () -> KeyedJSONEncoder

    public init(keyOptions: KeyOptions = KeyOptions(delimiter: .character("."), flat: .emptyOrWhitespace),
                keyedJSONDecoder: @escaping () -> KeyedJSONDecoder = KeyedJSONDecoder.init,
                keyedJSONEncoder: @escaping () -> KeyedJSONEncoder = KeyedJSONEncoder.init) {

        self.keyOptions = keyOptions
        defaultJSONDecoder = keyedJSONDecoder
        defaultJSONEncoder = keyedJSONEncoder
    }
}
