//
//  ExampleModel.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 14/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation

enum ExampleType: CaseIterable {
    case boolSpecialCase, flatJSON, allKeys, optionalArrayElements, keyOptions
    
    func getJSON() -> String? {
        let resourceName: String
        switch self {
        case .boolSpecialCase:
            resourceName = "boolSpecialCase"
        case .flatJSON:
            resourceName = "flatJSON"
        case .allKeys:
            resourceName = "allKeys"
        case .optionalArrayElements:
            resourceName = "optionalArrayElements"
        case .keyOptions:
            resourceName = "keyOptions"
        }
        return getStringForResource(name: resourceName)
    }
    
    func parseJSON() throws -> Decodable  {
        guard
            let json = getJSON(),
            let jsonData = json.data(using: .utf8)
            else {
                throw NSError(domain: "recurso json no disponible", code: 0, userInfo: nil)
        }
        
        let obj: Decodable
        
        do {
            switch self {
            case .boolSpecialCase:
                obj = try JSONDecoder().decode(BoolSpecialCase.self, from: jsonData)
            case .flatJSON:
                obj = try JSONDecoder().decode(ShopDTO.self, from: jsonData)
            case .allKeys:
                obj = try JSONDecoder().decode(PaymentMethods.self, from: jsonData)
            case .optionalArrayElements:
                obj = try JSONDecoder().decode(OptionalArray.self, from: jsonData)
            case .keyOptions:
                obj = try JSONDecoder().decode(KeyOptionsExampleDTO.self, from: jsonData)
            }
        } catch {
            print(error)
            throw error
        }
        return obj
    }
    
    func getImplementation() -> String? {
        switch self {
        case .boolSpecialCase:
            return BoolSpecialCase.implementation
        case .flatJSON:
            return ShopDTO.implementation
        case .allKeys:
            return PaymentMethods.implementation
        case .optionalArrayElements:
            return OptionalArray.implementation
            case .keyOptions:
            return KeyOptionsExampleDTO.implementation
        }
    }
    
    func getTypeName() -> String? {
        switch self {
        case .boolSpecialCase:
            return String(describing: BoolSpecialCase.self)
        case .flatJSON:
            return String(describing: ShopDTO.self)
        case .allKeys:
            return String(describing: PaymentMethods.self)
        case .optionalArrayElements:
            return String(describing: OptionalArray.self)
        case .keyOptions:
            return String(describing: KeyOptionsExampleDTO.self)
        }
    }
}

struct Example {
    let type: ExampleType
    let title: String
    let description: String
    let detailedDescription: String
    
    init(type: ExampleType) {
        self.type = type
        switch type {
        case .boolSpecialCase:
            title = NSLocalizedString("SDOSKeyedCodableExample.type.boolSpecialCase.name", comment: "")
            description = NSLocalizedString("SDOSKeyedCodableExample.type.boolSpecialCase.description", comment: "")
            detailedDescription = NSLocalizedString("SDOSKeyedCodableExample.type.boolSpecialCase.detailedDescription", comment: "")
        case .flatJSON:
            title = NSLocalizedString("SDOSKeyedCodableExample.type.flat.name", comment: "")
            description = NSLocalizedString("SDOSKeyedCodableExample.type.flat.description", comment: "")
            detailedDescription = NSLocalizedString("SDOSKeyedCodableExample.type.flat.detailedDescription", comment: "")
        case .allKeys:
            title = NSLocalizedString("SDOSKeyedCodableExample.type.allKeys.name", comment: "")
            description = NSLocalizedString("SDOSKeyedCodableExample.type.allKeys.description", comment: "")
            detailedDescription = NSLocalizedString("SDOSKeyedCodableExample.type.allKeys.detailedDescription", comment: "")
        case .optionalArrayElements:
            title = NSLocalizedString("SDOSKeyedCodableExample.type.optionalArrayElements.name", comment: "")
            description = NSLocalizedString("SDOSKeyedCodableExample.type.optionalArrayElements.description", comment: "")
            detailedDescription = NSLocalizedString("SDOSKeyedCodableExample.type.optionalArrayElements.detailedDescription", comment: "")
        case .keyOptions:
            title = NSLocalizedString("SDOSKeyedCodableExample.type.keyOptions.name", comment: "")
            description = NSLocalizedString("SDOSKeyedCodableExample.type.keyOptions.description", comment: "")
            detailedDescription = NSLocalizedString("SDOSKeyedCodableExample.type.keyOptions.detailedDescription", comment: "")
        }
    }
}


fileprivate func getStringForResource(name: String) -> String? {
    if
        let filePath = Bundle.main.path(forResource: name, ofType: "txt"),
        let jsonStr = try? String(contentsOfFile: filePath) {
        return jsonStr
    } else {
        return nil
    }
    
}
