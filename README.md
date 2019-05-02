
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/KeyedCodable.svg?style=flat)](https://cocoapods.org/pods/KeyedCodable)
[![License](https://img.shields.io/cocoapods/l/KeyedCodable.svg?style=flat)](https://cocoapods.org/pods/KeyedCodable)
[![Platform](https://img.shields.io/cocoapods/p/KeyedCodable.svg?style=flat)](https://cocoapods.org/pods/KeyedCodable)

![](/keyedCodable.gif) 

# Is this another JSON parsing library ? 

*KeyedCodable* is an addition to swift's *Codable* introduced in swift 4. It’s great we can use automatic implementation of *Codable* methods but when we have to implement them manually it often brings boilerplate code - especially when you need both to encode and decode nested keys in complicated JSON's structure. 

# The goal 

The goal it to avoid manual implementation of *Encodable/Decodable* and make encoding/decoding easier, more readable, less boilerplate and what is the most important fully compatible with 'standard' *Codable*. 

## How to use?

To support *KeyedCodable* you have to use ```KeyedJSONEncoder```/```KeyedJSONDecoder``` in place of standard ```JSONEncoder```/```JSONDecoder``` and use ```KeyedKey``` intead of ```CodingKey``` for your ```CodingKeys``` enums. *Keyed* versions are the wrappers around (inherits from) standard versions so they are fully compatible. 

# Inner keys (comparison with example from Apple)
First, please have a look on Codable example provided by Apple.
## vanilla Codable example:
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

## using KeyedCodable:
```swift
struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
    var elevation: Double
    
    enum CodingKeys: String, KeyedKey {
        case latitude
        case longitude
        case elevation = "additionalInfo.elevation"
    }
}
```
By using *KeyedCodable* you don't need to implement ```Codable``` manually so it require a lot less code even for single nested property. 

**By default dot is used as delimiter to separate the inner keys**

# Flat classes
Sometimes you may get the json with all properties in one big class. Flat feature allows you to group properties into smaller classes. It may be also useful for grouping not required properties. 

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

struct InnerWithFlatExample: Codable {
    let greeting: String
    let location: Location?

    enum CodingKeys: String, KeyedKey {
        case greeting = "inner.greeting"
        case location = ""
    }
}
```

In this example two use cases are shown: 
- longitude and latitude are placed in json main class but we 'moved' them into separate struct called Location 
- both longitude and latitude are optional. If both or one of them are missing then location property will be nil.

**By default empty string or whitespaces are used to mark flat class**

# Flat arrays
By default decoding of whole array will fail if decoding of any array's element fails. Sometimes instead of having empty list it would be better to have a list that contains all valid elements and omits wrong ones
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

struct OptionalArrayElementsExample: Codable {
    let array: [ArrayElement]

    enum CodingKeys: String, KeyedKey {
        case array = ".array"
    }
}
```

In example above ```array``` property will contain three elements [1,3,4] even though decoding second element 'fails'.

**You can mark your flat array by prefixing the array's name by 'flat + delimiter' so it is 'empty string + dot' by default**

# KeyOptions

It may happen that keys in the json will conflict with delimiters used by ```KeyedCodable``` - eg. dots used for nested keys. In situations like that you may configure mapping features (delimiters and flat strings) and also you may disable the feature at all. You may do that by providing ```options: KeyOptions?``` property in your CodingKeys (please return ```nil``` to use the default ```KeyOptions``` ).
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
struct KeyOptionsExample: Codable {
    let greeting: String
    let description: String
    let name: String
    let location: Location
    let array: [ArrayElement]
    let array1: [ArrayElement]


    enum CodingKeys: String, KeyedKey {
        case location = "__"
        case name = "* name"
        case greeting = "+.greeting"
        case description = ".details.description"

        case array = "### .array"
        case array1 = "### .* array1"

        var options: KeyOptions? {
            switch self {
            case .greeting: return KeyOptions(delimiter: .character("+"), flat: .none)
            case .description: return KeyOptions(flat: .none)
            case .location: return KeyOptions(flat: .string("__"))
            case .array, .array1: return KeyOptions(flat: .string("### "))
            default: return nil
            }
        }
    }
}
```
## Migration to 2.0.0 version 

Unfortunately 2.0.0 version is not compatible with 1.x.x versions but I believe that new way is much better and it brings less boilerplate than previous versions. There is no need to add any manual mapping implementation, it's really simple so I strongly recommend to migrate to new version. All you need is to: 
- use ```KeyedJSONEncoder``` \ ```KeyedJSONDecoder``` instead of ```JSONEncoder``` \ ```JSONDecoder``` !!
- change you CodingKeys to ```KeyedKey``` and move your mappings here
- remove ```KeyedCodable``` protocol
- remove constructor and map method
