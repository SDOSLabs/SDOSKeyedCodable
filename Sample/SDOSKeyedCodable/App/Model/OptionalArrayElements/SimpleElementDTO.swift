//
//  Shop.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 14/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation
import SDOSKeyedCodable


struct SimpleElementDTO: Decodable {
    var id: Int = 0
    var name: String?
}

struct OptionalArray: Decodable, Keyedable {
    private(set) var array: [SimpleElementDTO]!
    
    mutating func map(map: KeyMap) throws {
        try array <<- map["* elements"]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}

extension OptionalArray: ExampleProtocol {
    
    static var implementation: String? {
        return """
        struct SimpleElementDTO: Decodable {
            var id: Int = 0
            var name: String?
        }
        
        struct OptionalArray: Decodable, Keyedable {
            private(set) var array: [SimpleElementDTO]!
        
            mutating func map(map: KeyMap) throws {
                try array <<- map["* elements"]
            }
        
            init(from decoder: Decoder) throws {
                try KeyedDecoder(with: decoder).decode(to: &self)
            }
        }
        """
    }
}
