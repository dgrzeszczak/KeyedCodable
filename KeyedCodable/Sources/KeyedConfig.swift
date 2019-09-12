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

    public init(keyOptions: KeyOptions = KeyOptions(delimiter: .character("."), flat: .emptyOrWhitespace)) {
        self.keyOptions = keyOptions
    }
}


