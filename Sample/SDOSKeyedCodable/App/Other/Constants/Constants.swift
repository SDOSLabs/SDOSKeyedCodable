//
//  Constants.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 13/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation

struct Constants {
    private init() {}
    
    struct Documentation {
        private init() { }
        
        static let url = "https://kc.sdos.es/display/IOS/SDOSKeyedCodable"
    }
    
    struct Navigation {
        private init() { }
        
        static let goBackButtonTitle = "<"
        static let goForwardButtonTitle = ">"
    }
    
    struct App {
        private init() { }
        
        static var versionStringFormat: String {
            return NSLocalizedString("SDOSKeyedCodableExample.version", comment: "")
        }
    }
}
