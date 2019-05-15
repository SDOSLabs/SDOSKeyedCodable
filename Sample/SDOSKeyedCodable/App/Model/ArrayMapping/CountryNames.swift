//
//  CountryNames.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 15/05/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation
import SDOSKeyedCodable

struct CountryNames: Decodable, Keyedable {
    
    var name: String?
    var citizenNames: [String]? = [String]()
    
    mutating func map(map: KeyMap) throws {
        try name <<- map["country.name"]
        try citizenNames <<- map["[]country.cities.citizens.name"]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
    
}

extension CountryNames: ExampleProtocol {
    
    static var implementation: String? {
        return """
        var name: String?
        var citizenNames = [String]()
        
        mutating func map(map: KeyMap) throws {
            try name <<- map["country.name"]
            try citizenNames <<- map["[]country.cities.citizens.name"]
        }
        """
    }
}
