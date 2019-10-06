
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/KeyedCodable.svg?style=flat)](https://cocoapods.org/pods/KeyedCodable)
[![License](https://img.shields.io/cocoapods/l/KeyedCodable.svg?style=flat)](https://cocoapods.org/pods/KeyedCodable)
[![Platform](https://img.shields.io/cocoapods/p/KeyedCodable.svg?style=flat)](https://cocoapods.org/pods/KeyedCodable)

![](/keyedCodable.gif) 

# The goal 

*KeyedCodable* is an addition to swift's *Codable* and it's designed for automatic nested key mappings. The goal it to avoid manual implementation of *Encodable/Decodable* and make encoding/decoding easier, more readable, less boilerplate and what is the most important fully compatible with 'standard' *Codable*. 

# Nested keys
First, please have a look on Codable example provided by Apple.
### vanilla Codable:
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

### KeyedCodable:
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

*By default dot is used as delimiter to separate the inner keys*

# @Flat classes
Flat classes feature allows you to group properties into smaller parts. In the example below you can see that: 
- longitude and latitude are placed in json's main class but it is 'moved' into separate struct ```Location``` in the swift's model
- both longitude and latitude are optional. If any of them is missing, the location property will be nil.

### Example JSON:
```json
{
    "longitude": 3.2,
    "latitude": 3.4,
    
    "greeting": "hallo"
}
```

### KeyedCodable:
```swift
struct InnerWithFlatExample: Codable {
    @Flat var location: Location?
    
    let greeting: String
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}
```

<details>
  <summary>Without property wrappers</summary>
  
```swift
struct InnerWithFlatExample: Codable {
    let location: Location?
    
    let greeting: String

    enum CodingKeys: String, KeyedKey {
        case greeting
        case location = ""
    }
}
```

*By default empty string or whitespaces are used to mark flat class*
</details>

# @Flat arrays
Probably you found out that decoding an array will fail if decoding of any array's element fails. Flat array *KeyedCodable's* feature omits incorrect elements and creates array that contain valid elements only. In example below ```array``` property will contain three elements [1,3,4] though decoding second element fails.

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
### KeyedCodable:
```swift
struct OptionalArrayElementsExample: Codable {
    @Flat var array: [ArrayElement]
}

struct ArrayElement: Codable {
    let element: Int
}
```

<details>
<summary>Without property wrappers</summary>

```swift
struct OptionalArrayElementsExample: Codable {
    let array: [ArrayElement]

    enum CodingKeys: String, KeyedKey {
        case array = ".array"
    }
}
```

*To enable flat array you have to add [flat][delimiter] before property name - by defult it is 'empty string + dot'*
</details>

# KeyOptions

In case of conflicts between json's keys and delimiters used by ```KeyedCodable```, you may use ```KeyOptions``` to configure mapping features. You may do that by providing ```options: KeyOptions?``` property in your CodingKeys ( use ```nil``` to use default value). You may also disable the feature by setting ```.none``` value. 

<details>
<summary>Examples</summary>

### Example JSON:
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
    "latitude": 3.4,
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
### KeyedCodable:
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
</details>

# @Zero as default value

@Zero feature sets default "zero" value for the property in case value is not set in the JSON (no key at all or null value is set). If you find the situation there is no difference between 0 and nil from the business perspective you can easily get rid off optional from your codable.

### Example JSON:
```json
{
    "name": "Jan"
}
```

### KeyedCodable:
```swift
struct ZeroTestCodable: Codable {
    var name: String                    // Jan
    
    @Zero var secondName: String        // "" - empty string
    @Zero var numberOfChildren: Int     // 0
    @Zero var point: Point              // Point(x: 0.0, y: 0.0)
}

struct Point: Codable {
    let x: Float
    let y: Float
}
```

# Transformers - @CodedBy, @EncodedBy, @DecodedBy

Have you ever had a need of decoding a JSON having multiple Date formats in it ? Or maybe you had to add custom transformation from one value to another during decode/encode process and you had to write a lot of boilerplate code for manual coding ? Transformers are designed for making custom transformation a lot easier ! 

To add your custom transformer you have to implement ```DecodableTransformer```, ```EncodableTransformer``` or ```Transformer``` for two way transformation. 

## Date formater example 

### Example JSON:
```json
{
    "date": "2012-05-01"
}
```

### Usage 
```swift
struct DateCodableTrasform: Codable {

    @CodedBy<DateTransformer> var date: Date
}
```

### Transformer
```swift
enum DateTransformer<Object>: Transformer {

    static func transform(from decodable: String) -> Any? {
        return formatter.date(from: decodable)
    }

    static func transform(object: Object) -> String? {
        guard let object = object as? Date else { return nil }
        return formatter.string(from: object)
    }
    
    
    private static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
```

## Non codable formater example 

You can even implement transformer for non Codable model and use it in you Codable tree like that:

### Example JSON:
```json
{
    "user": 3
}
```

### Usage 
```swift
struct DetailPage: Codable {

    @CodedBy<UserTransformer> var user: User
}

struct User {           // User do not implement Codable protocol
    let id: Int
}
```

### Transformer
```swift
enum UserTransformer<Object>: Transformer {
    static func transform(from decodable: Int) -> Any? {
        return User(id: decodable)
    }

    static func transform(object: Object) -> Int? {
        return (object as? User)?.id
    }
}
```

# How to use?

To support nested key mappings you need to use ```KeyedKey``` intead of ```CodingKey``` for your ```CodingKeys``` enums and  ```KeyedJSONEncoder```/```KeyedJSONDecoder``` in place standard ```JSONEncoder```/```JSONDecoder```. Please notice that *Keyed* coders inherit from standard equivalents so they are fully compatible with Apple versions. 

### Codable extensions

```swift
struct Model: Codable {
    var property: Int
}
```
Decode from string:
```swift 
let model = try Model.keyed.fromJSON(jsonString)
```
Decode from data: 
```swift
let model = try Model.keyed.fromJSON(data)
```
Endcode to string: 
```swift
model.keyed.jsonString() 
```

Encode to data: 
```swift
model.keyed.jsonData() 
```

*You can provide coders in method parameters in case you need additional setup*

### Coders 

You can also use *Keyed* coders the same way as standard versions. 

```swift
let model = try KeyedJSONDecoder().decode(Model.self, from: data)
```
```swift
let data = try KeyedJSONEncoder().encode(model)
```

It's worth to mention that *Keyed* coders supports simple types ie. ```String```, ```Int``` etc. 
For example when we try to decode ```Int``` using standard ```JSONDecoder``` 
```swift
let number = try JSONDecoder().decode(Int.self, from: data)
```
it will throw an incorrect format error. Keyed version will parse that with success. 

### Keyed<> wrapper

There is a possibility to use standard JSON coders and still encode/decode *KeyedCodables*. To do that you have to use ```Keyed<>``` wrapper: 
```swift
let model = try JSONDecoder().decode(Keyed<Model>.self, from: data).value
```
```swift
let data = try JSONEncoder().encode(Keyed(model))
```

It may be useful in case you do not have an access to coder's initialization code. In that situation your model may looks like that: 

```swift
struct KeyedModel: Codable { 
... 

    enum CodingKeys: String, KeyedKey {
        ....
    }
.... 
}

struct Model { 
    
    let keyed: Keyed<KeyedModel>    
}
```

### Manual nested key coding

In case you need implement *Codable* manually you can use ```AnyKey``` for simpler access to nested keys. 

```swift
private let TokenKey = AnyKey(stringValue: "data.tokens.access_token")

struct TokenModel: Codable {

    let token: Token

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyKey.self)
        token = try container.decode(Token.self, forKey: TokenKey)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy:  AnyKey.self)
        try container.encode(token, forKey: TokenKey)
    }
}
```

### KeyedConfig

As mentioned earlier there is possibility to setup key options eg. delimiters on ```KeyedKey``` level but there is also possibility to setup it globally. 

To do that you need to set the value of  ```KeyedConfig.default.keyOptions```. 

Beside key opptions there is also possibility to setup coders used by default in *Codable* extensions.

## Migration to 3.x.x version 

Version 3.0.0 is backward compatible with version 2.x.x however you have to use **swift 5.1** for all new features connected with ```@PropertyWrapper```s. 

## Migration to 2.x.x version 

Unfortunately 2.x.x version is not compatible with 1.x.x versions but I believe that new way is much better and it brings less boilerplate than previous versions. There is no need to add any manual mapping implementation, it's really simple so I strongly recommend to migrate to new version. All you need is to: 
- use ```KeyedJSONEncoder``` \ ```KeyedJSONDecoder``` instead of ```JSONEncoder``` \ ```JSONDecoder``` !!
- change you CodingKeys to ```KeyedKey``` and move your mappings here
- remove ```KeyedCodable``` protocol
- remove constructor and map method
