//
//  Keyedable.swift
//  KeyedCodable
//
//  Created by Dariusz Grzeszczak on 26/03/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol Keyedable {

    /// This method must be used to define the mappings for the object. Use operator '`<<-`' for decoding only, use '`->>`' for encoding or use '`<->`' for both decoding and encoding.
    /// - important: Decoding requires the type to implement `init(from:)` and Encoding requires the type to implement `encode(to:)`.
    /// - Parameter map: The map object used to encode/decode the object.
    /// - Throws: An error that can be thrown due to encoding or decoding.
    mutating func map(map: KeyMap) throws
}

public extension Keyedable where Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        try KeyedEncoder(with: encoder).encode(from: self)
    }
}
