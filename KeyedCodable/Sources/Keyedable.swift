//
//  Keyedable.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//

// TOOD UNIT tests, move KeyMap implementation from KeyedCodables, transformers?

public protocol Keyedable {
    mutating func map(map: KeyMap) throws
}

// You can use Keyedable with standard Codables in json tree!

// implementation of Keyedable
//
//struct Test: Codable, Keyedable {
//    var someString: String?
//
//    //specify keys
//    enum CodingKeys: String, CodingKey {
//        case someString = "key"
//    }
//
//    // use KeyedDecoder in ctor
//    init(from decoder: Decoder) throws {
//        try KeyedDecoder(with: decoder).map(to: &self)
//    }
//
//    // use KeyedEncoder in encode function
//    func encode(to encoder: Encoder) throws {
//        try KeyedEncoder(with: encoder).map(from: self)
//    }
//
//    // use map
//    mutating func map(map: KeyMap) throws {
//        try someString <-> map[CodingKeys.someString]
//    }
//}

// key maps

//********** 1) inner values

//json:
//{
//    "inner": {
//        "string": "someValue"
//    }
//}

// keys:
//enum CodingKeys: String, CodingKey {
//    case someString = "inner.string"
//}

// mapping:
//try someString <-> map[CodingKeys.someString]

//********** 2) flat class

//!!!!! Important  !!!
//!!!!! it's recomended to use before other mappings (on begining of map() function)
//!!!!! due to swift issue it may throw strange error when used after "optional array elements" mapping
//
// ==== it seems it is fixed in swift 4.1 but need to be retested

//json:
//{
//    "someString": "sameString",
//     "longitude": 3.4,
//     "lattitude": 3.4
//}

//struct Location: Codable {
//    let lattitude: Int
//    let longitude: Int
//}

// keys:
//enum CodingKeys: String, CodingKey {
//    case someString
//    case location = ""
//}

// mapping:
//    try location <-> map[CodingKeys.location]
//    try someString <-> map[CodingKeys.someString]

//********** 3) optional array elements

// by default parsing all array will fail when any of element fail
// you can mark array an optional - so it will ommit element that couldn't be parsed (eg. some field missing)

//json:
//"someClass": {
//    "booleanInClass": false,
//    "array": [
//    {
//    "element": 1
//    },
//    {},
//    {
//    "element": 3
//    },
//    {
//    "element": 4
//    }
//    ],
//    "intInClass": 3
//},

// keys:
//enum CodingKeys: String, CodingKey {
//    ...
//    case array = "* array"
//    ....
//}

//struct ArrayElement: Codable {
//    let element: Int
//}

// mapping:
// try array <-> map[CodingKeys.array]

// result
// returns array with 3 elements, empty element will be omitted

//********** KeyOptions
// sometimes you may need to disable some of the functionality or change it. Eg dot is used in json property identifie.
// You can configure it by passing KeyOptions value to the maping.

//public struct KeyOptions {
//    public let delimiter: String?
//    public let flat: String?
//    public let optionalArrayElements: String?

//eg. use '+' for inner clases delimiter instead of '.'

// mapping:
//try innerString <-> map[CodingKeys.innerString, KeyOptions(delimiter: "+")]

// key:
//enum CodingKeys: String, CodingKey {
//    case innerString = "innerClassTest+innerString"
//}
