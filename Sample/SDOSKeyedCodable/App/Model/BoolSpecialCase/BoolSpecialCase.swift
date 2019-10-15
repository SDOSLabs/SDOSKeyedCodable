//
//  BoolSpecialCase.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 13/05/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation
import SDOSKeyedCodable

struct BoolSpecialCase: Decodable, Keyedable {
    
    var boolStringTrue: Bool!
    var boolStringFalse: Bool!
    var boolStringYes: Bool!
    var boolStringNo: Bool!
    var boolString0: Bool!
    var boolString1: Bool!
    var boolInt1: Bool!
    var boolInt0: Bool!
    
    mutating func map(map: KeyMap) throws {
        try boolStringTrue  <<- map["stringTrue"]
        try boolStringFalse <<- map["stringFalse"]
        try boolStringYes   <<- map["stringYes"]
        try boolStringNo    <<- map["stringNo"]
        try boolString0     <<- map["string0"]
        try boolString1     <<- map["string1"]
        try boolInt1        <<- map["int1"]
        try boolInt0        <<- map["int0"]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
    
}

extension BoolSpecialCase: ExampleProtocol {
    
    static var implementation: String? {
        return """
        var boolStringTrue: Bool!
        var boolStringFalse: Bool!
        var boolString0: Bool!
        var boolString1: Bool!
        var boolInt1: Bool!
        var boolInt0: Bool!
        
        mutating func map(map: KeyMap) throws {
            try boolStringTrue  <<- map["stringTrue"]
            try boolStringFalse <<- map["stringFalse"]
            try boolStringYes   <<- map["stringYes"]
            try boolStringNo    <<- map["stringNo"]
            try boolString0     <<- map["string0"]
            try boolString1     <<- map["string1"]
            try boolInt1        <<- map["int1"]
            try boolInt0        <<- map["int0"]
        }
        """
    }
}
