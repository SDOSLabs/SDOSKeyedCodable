//
//  PaymentMethod.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 14/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation
import SDOSKeyedCodable

struct KeyOptionsExampleDTO: Codable, Keyedable {
    private(set) var greeting: String!
    private(set) var description: String!
    private(set) var name: String!
    private(set) var location: Location!
    private(set) var array: [SimpleElementDTO]!
    private(set) var array1: [SimpleElementDTO]!
    
    mutating func map(map: KeyMap) throws {
        try name <<- map["* name"]
        try greeting <<- map["+.greeting", KeyOptions(delimiter: "+", flat: nil)]
        try description <<- map[".details.description", KeyOptions(flat: nil)]
        try location <<- map["", KeyOptions(flat: "__")]
        try array <<- map["* array"]
        try array1 <<- map["### * array1", KeyOptions(optionalArrayElements: "### ")]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}


extension KeyOptionsExampleDTO: ExampleProtocol {
    
    static var implementation: String? {
        return """
        struct KeyOptionsExample: Codable, Keyedable {
            private(set) var greeting: String!
            private(set) var description: String!
            private(set) var name: String!
            private(set) var location: Location!
            private(set) var array: [ArrayElement]!
            private(set) var array1: [ArrayElement]!
        
            mutating func map(map: KeyMap) throws {
                try name <<- map["* name"]
                try greeting <<- map["+.greeting", KeyOptions(delimiter: "+", flat:         nil)]
                try description <<- map[".details.description", KeyOptions(flat: nil)]
                try location <<- map["", KeyOptions(flat: "__")]
                try array <<- map["* array"]
                try array1 <<- map["### * array1", KeyOptions(optionalArrayElements: "### ")]
            }
        
            init(from decoder: Decoder) throws {
                try KeyedDecoder(with: decoder).decode(to: &self)
            }
        }

        """
    }
}
