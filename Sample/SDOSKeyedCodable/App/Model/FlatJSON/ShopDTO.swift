//
//  Shop.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 14/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation
import CoreLocation
import SDOSKeyedCodable

struct Location: Decodable {
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
}

struct ShopDTO: Decodable, Keyedable {
    
    var name: String!
    var location: Location?
    
    mutating func map(map: KeyMap) throws {
        try name     <<- map["shop_name"]
        try location <<- map[""]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
    
}

extension ShopDTO: ExampleProtocol {
    
    static var implementation: String? {
        return """
        var name: String!
        var location: Location?
        
        mutating func map(map: KeyMap) throws {
            try name     <<- map["shop_name"]
            try location <<- map[""]
        }
        """
    }
}
