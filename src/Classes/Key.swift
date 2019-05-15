//
//  Key.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public struct Key: CodingKey {
    public let stringValue: String

    public init(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public let intValue: Int?

    public init(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension CodingKey {
    
    func keys(for options: KeyOptions) -> [Key] {
        return stringValue
            .components(separatedBy: options.delimiter ?? "")
            .compactMap { Key(stringValue: $0) }
    }
    
}
