//
//  PaymentMethod.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 14/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation
import SDOSKeyedCodable

struct PaymentMethodDTO: Decodable {
    var type: String?
}

struct PaymentMethods: Decodable, Keyedable {
    var userPaymentMethods: [PaymentMethodDTO] = []
    
    mutating func map(map: KeyMap) throws {
        guard case .decoding(let keys) = map.type else { return }
        
        let allKeys = keys.all(for: Key(stringValue: "vault"))//all(for: CodingKey(stringValue: "vault"))
            
            allKeys.forEach {
                var paymentMethod: PaymentMethodDTO?
                try? paymentMethod <<- map[$0]
                if let paymentMethod = paymentMethod {
                    userPaymentMethods.append(paymentMethod)
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}

extension PaymentMethods: ExampleProtocol {
    
    static var implementation: String? {
        return """
        struct PaymentMethod: Decodable {
            var type: String?
        }
        
        struct PaymentMethods: Decodable, Keyedable {
            var userPaymentMethods: [PaymentMethod] = []
        
            mutating func map(map: KeyMap) throws {
                guard case .decoding(let keys) = map.type else { return }
        
                let allKeys = keys.all(for: Key(stringValue: "vault"))//all(for: CodingKey(stringValue: "vault"))
        
                allKeys.forEach {
                    var paymentMethod: PaymentMethod?
                    try? paymentMethod <<- map[$0]
                    if let paymentMethod = paymentMethod {
                        userPaymentMethods.append(paymentMethod)
                    }
                }
            }
        
            init(from decoder: Decoder) throws {
                try KeyedDecoder(with: decoder).decode(to: &self)
            }
        }
        """
    }
}
