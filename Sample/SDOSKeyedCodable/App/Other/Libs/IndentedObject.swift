//
//  IndentedObject.swift
//  SDOSKeyedCodable_Example
//
//  Created by Antonio Jesús Pallares on 14/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation

struct DetailSection {
    let title: String?
    let objects: [IndentedObject]
}

struct IndentedObject {
    let indentationLevel: Int
    let text: String?
    let children: [IndentedObject]
    
    init(indentationLevel: Int, text: String?, children: [IndentedObject] = []) {
        self.indentationLevel = indentationLevel
        self.text = text
        self.children = children
    }
    
    var textToShow: String? {
        var str = String(repeating: ">", count: indentationLevel)
        str.append(" ")
        str.append(text ?? "")
        return str
    }
    
    var hasChildren: Bool {
        return children.count > 0
    }
    
    static func getPlainListOfIndentedObjects(from object: Any) -> [IndentedObject] {
        let objects = getIndentedObjects(from: object, indentationLevel: 0)
        return flatten(indentedObjects: objects)
    }
    
    static func getIndentedObjects(from object: Any, indentationLevel level: Int = 0) -> [IndentedObject] {
        var obj = object
        if case Optional<Any>.some(let val) = obj {
            obj = val
        }
        if let array = obj as? [Any] {
            return array.enumerated().flatMap { (offset: Int, element: Any) -> [IndentedObject] in
                var ans = [IndentedObject(indentationLevel: level, text: "Index \(offset): \(String(describing: type(of: element)))")]
                ans.append(contentsOf: self.getIndentedObjects(from: element, indentationLevel: level + 1))
                return ans
            }
        }
        let mirror = Mirror(reflecting: obj)
        return mirror.children.map { (label: String?, value: Any) -> IndentedObject in
            if let val = value as? StringRepresentable {
                let text = getFinalStringFor(label: label, value: val)
                return IndentedObject(indentationLevel: level, text: text)
            } else {
                let text = getFinalStringFor(label: label, value: value)
                let objects = getIndentedObjects(from: value, indentationLevel: level + 1)
                return IndentedObject(indentationLevel: level, text: text, children: objects)
            }
        }
    }
    
    private static func flatten(indentedObjects: [IndentedObject]) -> [IndentedObject] {
        var finalArray = [IndentedObject]()
        for obj in indentedObjects {
            finalArray.append(obj)
            if obj.children.count > 0 {
                finalArray.append(contentsOf: flatten(indentedObjects: obj.children))
            }
        }
        return finalArray
    }
    
    private static func getFinalStringFor(label: String?, value: StringRepresentable) -> String {
        let lb = label ?? ""
        return "\(lb): \(String(describing: type(of: value))) = \(value.toString())"
    }
    
    private static func getFinalStringFor(label: String?, value: Any) -> String {
        let lb = label ?? ""
        var text = "\(lb): \(String(describing: type(of: value)))"
        if case Optional<Any>.none = value {
            text.append(" = nil")
        }
        return text
    }
}

protocol StringRepresentable {
    func toString() -> String
}

extension StringRepresentable {
    func toString() -> String {
        return String(describing: self)
    }
}

extension Double: StringRepresentable { }
extension Int: StringRepresentable { }
extension Bool: StringRepresentable { }
extension String: StringRepresentable { }
extension Optional: StringRepresentable where Wrapped: StringRepresentable {
    
    func toString() -> String {
        switch self {
        case .some(let value):
            return value.toString()
        default:
            return "nil"
        }
    }
}
extension Dictionary: StringRepresentable { }
extension Array: StringRepresentable where Element: StringRepresentable { }
