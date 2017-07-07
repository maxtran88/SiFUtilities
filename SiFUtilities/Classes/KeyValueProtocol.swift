//
//  KeyValueProtocol.swift
//  SiFUtilities
//
//  Created by NGUYEN CHI CONG on 11/9/16.
//  Copyright © 2016 NGUYEN CHI CONG. All rights reserved.
//

import Foundation

public protocol KeyValueProtocol {}

func unwrap(any:Any) -> Any? {
    let mi = Mirror(reflecting: any)
    
    if let style = mi.displayStyle, style != .optional {
        return any
    }
    
    if mi.children.count == 0 { return nil }
    let (_, some) = mi.children.first!
    return some
    
}

public extension KeyValueProtocol {
    public var dictionary: [String: Any] {
        var dict = [String: Any]()
        let otherSelf = Mirror(reflecting: self)
        
        for child in otherSelf.children {
            if let key = child.label {
                if let value = child.value as? KeyValueProtocol {
                    dict[key] = value.dictionary
                }
                else if let values = child.value as? [KeyValueProtocol] {
                    dict[key] = values.map({ (item) -> [String: Any] in
                        return item.dictionary
                    })
                }
                else {
                    dict[key] = unwrap(any: child.value)
                }
            }
        }
        
        var mirror: Mirror = otherSelf
        
        while let superMirror = mirror.superclassMirror {
            for child in superMirror.children {
                if let key = child.label {
                    if let value = child.value as? KeyValueProtocol {
                        dict[key] = value.dictionary
                    }
                    else if let values = child.value as? [KeyValueProtocol] {
                        dict[key] = values.map({ (item) -> [String: Any] in
                            return item.dictionary
                        })
                    }
                    else {
                        dict[key] = unwrap(any: child.value)
                    }
                }
            }
            mirror = superMirror
        }
        
        return dict
    }
    
    public var JSONString: String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            return String(data: jsonData, encoding: String.Encoding.utf8)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public var keys: [String] {
        var results = [String]()
        let otherSelf = Mirror(reflecting: self)
        
        for child in otherSelf.children {
            if let key = child.label {
                results.append(key)
            }
        }
        
        var mirror: Mirror = otherSelf
        
        while let superMirror = mirror.superclassMirror {
            for child in superMirror.children {
                if let key = child.label {
                    results.append(key)
                }
            }
            mirror = superMirror
        }
        
        return results
    }
}

open class KeyValueObject: NSObject, KeyValueProtocol {
    public init(dictionary: [String: Any]) {
        super.init()
        self.setValuesForKeys(dictionary)
    }
    
    public override init() {
        super.init()
    }
}
