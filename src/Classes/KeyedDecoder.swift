//
//  KeyedDecoder.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public final class KeyedDecoder {

    private let keyMap: KeyMap
    public init(with decoder: Decoder) throws {
        keyMap = try KeyMap(keyMap: DecoderKeyMap(with: decoder))
    }

    public func decode<Type>(to object: inout Type) throws where Type: Decodable, Type: Keyedable {
        try object.map(map: keyMap)
    }

    public func decode<Type>(to object: Type) throws where Type: Decodable, Type: Keyedable, Type: AnyObject{
        var object = object
        try object.map(map: keyMap)
    }
}

private final class DecoderKeyMap: KeyMapBase {

    var type: MappingType { return .decoding(keys: self) }

    private let startingCodePath: [CodingKey]
    private let container: KeyedDecodingContainer<Key>
    private var containerDictionary: [String: KeyedDecodingContainer<Key>] = [:]
    private var unkeyedContainerDictionary: [String: UnkeyedDecodingContainer] = [:]
    private let decoder: Decoder

    init(with decoder: Decoder) throws {
        self.decoder = decoder
        container = try decoder.container(keyedBy: Key.self)
        startingCodePath = container.codingPath
        containerDictionary[startingCodePath.codePathString] = container
    }

    var userInfo: [CodingUserInfoKey: Any] {
        return decoder.userInfo
    }

    func decode<V>(object: inout V, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        if let flat = options.flat, flat == keyCode.stringValue {
            try object = V(from: decoder)
        } else {
            let result = try keyedDecodingContainer(for: keyCode, options: options)
            let val: V
            if let _val: V = decodeSpecialCase(type: V.self, container: result.container, key: result.key) {
                val = _val
            } else {
                val = try result.container.decode(V.self, forKey: result.key)
            }
            object = val
        }
    }

    func decode<V>(object: inout V?, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        if let flat = options.flat, flat == keyCode.stringValue {
            try? object = V(from: decoder)
        } else {
            let result = try keyedDecodingContainer(for: keyCode, options: options)
            let val: V?
            if let _val = decodeSpecialCase(type: V.self, container: result.container, key: result.key) {
                val = _val
            } else {
                val = try result.container.decodeIfPresent(V.self, forKey: result.key)
            }
            object = val
        }
    }

    func decode<V>(object: inout [V], with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        let result = try keyedDecodingContainer(for: keyCode, options: options)
        if  let optionalArrayElements = options.optionalArrayElements,
            !optionalArrayElements.isEmpty,
            result.key.stringValue.starts(with: optionalArrayElements) {
            let key = Key(stringValue: String(result.key.stringValue.dropFirst(optionalArrayElements.count))) // "optional" array

            var unkeyedContainer = try result.container.nestedUnkeyedContainer(forKey: key)
            var newObject = [V]()
            while !unkeyedContainer.isAtEnd {
                if let route = try? unkeyedContainer.decode(V.self) {
                    newObject.append(route)
                } else {
                    _ = try? unkeyedContainer.decode(EmptyCodable.self)
                }
            }
            object = newObject
        } else {
            let val = try result.container.decode([V].self, forKey: result.key)
            object = val
        }
    }

    func decode<V>(object: inout [V]?, with keyCode: CodingKey, options: KeyOptions) throws where V: Decodable {
        let result = try keyedDecodingContainer(for: keyCode, options: options)
        if  let optionalArrayElements = options.optionalArrayElements,
            !optionalArrayElements.isEmpty,
            result.key.stringValue.starts(with: optionalArrayElements) {
            let key = Key(stringValue: String(result.key.stringValue.dropFirst(optionalArrayElements.count))) // "optional" array

            var unkeyedContainer = try result.container.nestedUnkeyedContainer(forKey: key)
            var newObject = [V]()
            while !unkeyedContainer.isAtEnd {
                if let route = try? unkeyedContainer.decode(V.self) {
                    newObject.append(route)
                } else {
                    _ = try? unkeyedContainer.decode(EmptyCodable.self)
                }
            }
            object = newObject
        } else {
            let val = try result.container.decodeIfPresent([V].self, forKey: result.key)
            object = val
        }
    }

    private func keyedDecodingContainer(for keyCode: CodingKey, options: KeyOptions) throws -> (container: KeyedDecodingContainer<Key>, key: Key) {
        var keys = keyCode.stringValue
            .components(separatedBy: options.delimiter ?? "")
            .compactMap { Key(stringValue: $0) }
        guard !keys.isEmpty else { fatalError("encode failed - no key") }

        var codingPath = startingCodePath
        // initialize containers
        while keys.count != 1 {
            let key = keys.remove(at: 0)
            codingPath.append(key)
            if let arrayMappingIndicator = options.arrayMappingIndicator,  key.stringValue == arrayMappingIndicator {
                //TODO: Throw if keys.isEmpty at this point since an array mapping indicator "[]" cannot be the last component of the keyCode path
                try cacheUnkeyedDecodingContainer(for: codingPath)
            } else if
                let nextKey = keys.first,
                let arrayMappingIndicator = options.arrayMappingIndicator,
             nextKey.stringValue == arrayMappingIndicator
                {
                    keys.remove(at: 0) // We now know we should decode an array
                    // We do not add the nextKey.
                    // codingPath.append(nextKey)
                    // In this case, it is only used to indicate that the `key` references an array. If we had an array inside an array (and so on) then we would use the arrayMappingIndicator key and would append it to the codingPath (to differentiate between the different levels of arrays)
                    try cacheUnkeyedDecodingContainer(for: codingPath)
            } else {
                _ = try keyedDecodingContainer(for: codingPath)
            }
        }

        return (try keyedDecodingContainer(for: codingPath), keys[0])
    }

    private func keyedDecodingContainer(for codingPath: [CodingKey]) throws -> KeyedDecodingContainer<Key> {
        let codePathString = codingPath.codePathString
        if let cached = containerDictionary[codePathString] {
            return cached
        }
        
        guard let lastKey = codingPath[codingPath.count - 1] as? Key else {
            fatalError("KeyedDecoder - invalid key")
        }

        let parentCodePathString = codingPath.dropLast().codePathString
        
        if let parent = containerDictionary[parentCodePathString] {
            let container = try parent.nestedContainer(keyedBy: Key.self, forKey: lastKey)
            containerDictionary[codePathString] = container
            return container
        } else if var parent = unkeyedContainerDictionary[parentCodePathString] {
            let container = try parent.nestedContainer(keyedBy: Key.self)
            containerDictionary[codePathString] = container
            return container
        } else {
            fatalError("KeyedDecoder - no parent container")
        }
    }
    
    private func cacheUnkeyedDecodingContainer(for codingPath: [CodingKey]) throws {
        let codePathString = codingPath.codePathString
        if let cached = unkeyedContainerDictionary[codePathString] {
            return
        }
        
        guard let lastKey = codingPath[codingPath.count - 1] as? Key else {
            fatalError("KeyedDecoder - invalid key")
        }
        
        let parentCodePathString = codingPath.dropLast().codePathString
        var container: UnkeyedDecodingContainer? = nil
        if let parent = containerDictionary[parentCodePathString] {
            container = try parent.nestedUnkeyedContainer(forKey: lastKey)
        } else if var parent = unkeyedContainerDictionary[codePathString] {
            container = try parent.nestedUnkeyedContainer()
        }
        
        guard let unkeyedContainer = container else {
            fatalError("KeyedDecoder - no parent container")
        }
        unkeyedContainerDictionary[codePathString] = unkeyedContainer
    }
}

extension DecoderKeyMap: KeysCollection {
    func all(for keyCode: CodingKey, options: KeyOptions) -> [Key] {
        if let flat = options.flat, flat == keyCode.stringValue {
            return container.allKeys
        } else {
            guard let result = try? keyedDecodingContainer(for: keyCode, options: options) else { return [] }
            guard let container = try? result.container.nestedContainer(keyedBy: Key.self, forKey: result.key) else { return [] }
            return container.allKeys.compactMap {
                Key(stringValue: keyCode.stringValue + (options.delimiter ?? "") + $0.stringValue)
            }
        }
    }
}

// MARK: - Decoding special cases
// This extension defines methods to decode a boolean when the value from the JSON is either a string ("true", "1", "yes" or "false", "0", "no") or a integer (1 or 0).

private extension DecoderKeyMap {
    
    private static let acceptedTrueAsString: [String] = ["TRUE", "1", "YES"]
    private static let acceptedFalseAsString: [String] = ["FALSE", "0", "NO"]
    private static let acceptedTrueAsInt: [Int] = [1]
    private static let acceptedFalseAsInt: [Int] = [0]

    func decodeSpecialCase<V: Decodable>(type: V.Type, container: KeyedDecodingContainer<Key>, key: Key) -> V? {
        switch type {
        case is Bool.Type:
            return decodeSpecialCaseForBool(container: container, key: key) as? V
        default:
            return nil
        }
    }

    func decodeSpecialCaseForBool(container: KeyedDecodingContainer<Key>, key: Key) -> Bool? {
        if let str = try? container.decodeIfPresent(String.self, forKey: key) {
            let strUppercased = str.uppercased()
            switch strUppercased {
            case _ where DecoderKeyMap.acceptedTrueAsString.contains(strUppercased):
                return true
            case _ where DecoderKeyMap.acceptedFalseAsString.contains(strUppercased):
                return false
            default:
                return nil
            }
        } else if let int = try? container.decodeIfPresent(Int.self, forKey: key) {
            switch int {
            case _ where DecoderKeyMap.acceptedTrueAsInt.contains(int):
                return true
            case _ where DecoderKeyMap.acceptedFalseAsInt.contains(int):
                return false
            default:
                return nil
            }
        } else {
            return nil
        }
    }

}
