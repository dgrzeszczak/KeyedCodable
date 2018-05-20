[![CocoaPods](https://img.shields.io/cocoapods/v/ObjectMapper.svg)](https://github.com/dgrzeszczak/KeyedCodable)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Is this another JSON parsing library ? 

*KeyedCodable* is an addition to swift's *Codable* introduced in swift 4. It’s great we can use automatic implementation of *Codable* methods but when we have to implement them manually it often brings boilerplate code - especially when we need to implement both encoding and decoding methods for complicated JSON's structure. 

# The goal 

The goal it to make manual implementation of *Encodable/Decodable* easier, more readable, less boilerplate and what is the most important fully compatible with 'standard' *Codable*.

To support *KeyedCodable* you need to implement ```Keyedable``` protocol ie. implement ```map``` method:
```swift
func map(map: KeyMap) throws 
```
## Encoding

There is an default implementation of *Encodable’s* ```encode(to encoder: Encoder)``` method in *KeyedCodable*. If you need to change/override it please remember to call *KeyedEncoder* to make your mappings work.
```swift
func encode(to encoder: Encoder) throws {
	try KeyedEncoder(with: encoder).encode(from: self)
}
```
## Decoding 

If you are implementing Decodable you have to add constructor like this:

**for structs:**
```swift
init(from decoder: Decoder) throws {
	try KeyedDecoder(with: decoder).decode(to: &self)
}
```
**for classes:**
```swift
init(from decoder: Decoder) throws {
	try KeyedDecoder(with: decoder).decode(to: self)
}
```

Unfortunatelly there is one drawback of doing it that way. Because of properties are not initialized in constructor (decoding is moved to to ```map()``` function) we have to use *Optionals* and *Implicit Unwrapped Optionals*. *Optionals* are used for non required and *Implicit Unwrapped Optional* for required mappings.

## Map method implementation

You can use three operators for your mappings: 
- ```<->``` for Decoding and Encoding
- ```<<-``` for decoding only
- ```->>``` for encoding only

## Keyedable example:
```swift
    enum CodingKeys: String, CodingKey {
        case greeting = "inner.greeting"
        case description = "inner.details.description"
    }

    mutating func map(map: KeyMap) throws {
        try greeting <-> map[CodingKeys.greeting]
        try description <-> map[CodingKeys.description]
    }
```

or without the  ```CodingKeys``` : 

```swift
mutating func map(map: KeyMap) throws {
    try greeting <-> map["inner.greeting"]
    try description <-> map["inner.details.description"]
}
```

# Inner keys - Encode and Decode Manually - comparison with Apple example
First, please have a look on Codable example provided by Apple.
## Codable example:
```swift
struct Coordinate {
    var latitude: Double
    var longitude: Double
    var elevation: Double

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case additionalInfo
    }

    enum AdditionalInfoKeys: String, CodingKey {
        case elevation
    }
}

extension Coordinate: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)

        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        elevation = try additionalInfo.decode(Double.self, forKey: .elevation)
    }
}

extension Coordinate: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)

        var additionalInfo = container.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        try additionalInfo.encode(elevation, forKey: .elevation)
    }
}
```

## Using KeyedCodable:
```swift
struct Coordinate: Codable, Keyedable {
    var latitude: Double!
    var longitude: Double!
    var elevation: Double!

    mutating func map(map: KeyMap) throws {
        try latitude <-> map["latitude"]
        try longitude <-> map["longitude"]
        try elevation <-> map["additionalInfo.elevation"]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
```
You can notice that using *KeyedCodable* require lot less code even there is only one nested property in this example. 

**By default dot is used for separate the inner keys.*

# Flat classes
Sometimes you can have json with all properties in one big class. Flat feature allows you to group those properties in smaller classes. It can be also useful for grouping not required properties. 

## Example JSON
```json
{
    "inner": {
        "greeting": "hallo"
    },
    "longitude": 3.2,
    "lattitude": 3.4
}
```

## Keyedable
```swift
struct Location: Codable {
    let lattitude: Double
    let longitude: Double
}

struct InnerWithFlatExample: Codable, Keyedable {
    private(set) var greeting: String!
    private(set) var location: Location?

    enum CodingKeys: String, CodingKey {
        case greeting = "inner.greeting"
        case location = ""
    }

    mutating func map(map: KeyMap) throws {
        try greeting <-> map[CodingKeys.greeting]
        try location <-> map[CodingKeys.location]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
```

In this example two use cases are shown: 
- longitude and latitude are placed in json main class but we 'moved' them to struct called Location 
- both longitude and latitude are optional. If both or one of them are missing then location property will be nil.

**By default empty string is used to mark flat class*

# Optional array elements
By default decoding of array will fail if decoding of any array element fails. Sometimes instead of having empty list it would be better to have a list that contains all proper elements and omits wrong ones.
## Example JSON
```json
{
    "array": [
    {
    "element": 1
    },
    {},
    {
    "element": 3
    },
    {
    "element": 4
    }
    ]
}
```
## Keyedable
```swift
struct ArrayElement: Codable {
    let element: Int
}

struct OptionalArrayElementsExample: Codable, Keyedable {
    private(set) var array: [ArrayElement]!

    enum CodingKeys: String, CodingKey {
        case array = "* array"
    }

    mutating func map(map: KeyMap) throws {
        try array <-> map[CodingKeys.array]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
```

In example above ```array``` will contain three elements [1,3,4] even though decoding second element fails.

**By default ```* ``` (aterisk + space) is used to mark optional array*

# All keys
During decoding process you can get all possible keys 
## Example JSON
```json
{
    "vault": {
        "0": {
            "type": "Braintree_CreditCard"
        },
        "1": {
            "type": "Braintree_CreditCard"
        },
        "2": {
            "type": "Braintree_PayPalAccount"
        },
    }
}
```
## Keyedable
```swift

struct PaymentMethods: Decodable, Keyedable {

    private(set) var userPaymentMethods: [PaymentMethod] = []

    enum CodingKeys: String, CodingKey {
        case vault
    }

    mutating func map(map: KeyMap) throws {
        guard case .decoding(let keys) = map.type else { return }

        try keys.all(for: CodingKeys.vault).forEach { key in
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
```

# KeyOptions

It may happen that keys in your json file contain for example dots. In that situation you can disable or configure mapping features using ```KeyOptions``` parameter. You can set ```nil``` to disable feature at all or any ```String``` to change behaviour.
## Example JSON
```json
{
    "* name": "John",
    "": {
        ".greeting": "Hallo world",
        "details": {
            "description": "Its nice here"
        }
    },
    "longitude": 3.2,
    "lattitude": 3.4,
    "array": [
    {
    "element": 1
    },
    {},
    {
    "element": 3
    },
    {
    "element": 4
    }
    ],
    "* array1": [
    {
    "element": 1
    },
    {},
    {
    "element": 3
    },
    {
    "element": 4
    }
    ]
}
```
## Keyedable
```swift
struct KeyOptionsExample: Codable, Keyedable {
    private(set) var greeting: String!
    private(set) var description: String!
    private(set) var name: String!
    private(set) var location: Location!
    private(set) var array: [ArrayElement]!
    private(set) var array1: [ArrayElement]!


    enum CodingKeys: String, CodingKey {
        case location = "__"
        case name = "* name"
        case greeting = "+.greeting"
        case description = ".details.description"

        case array = "### array"
        case array1 = "### * array1"

    }

    mutating func map(map: KeyMap) throws {
        try name <-> map[CodingKeys.name]
        try greeting <-> map[CodingKeys.greeting, KeyOptions(delimiter: "+", flat: nil)]
        try description <-> map[CodingKeys.description, KeyOptions(flat: nil)]
        try location <-> map[CodingKeys.location, KeyOptions(flat: "__")]
        try array <-> map[CodingKeys.array, KeyOptions(optionalArrayElements: "### ")]
        try array1 <-> map[CodingKeys.array1, KeyOptions(optionalArrayElements: "### ")]
    }

    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
```
