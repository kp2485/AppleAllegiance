//
//  IpartIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

protocol IpartIGC: AnyObject {
    func getName() -> String
    // Add other necessary methods
}

// Default implementation
extension IpartIGC {
    func getName() -> String {
        return "Unknown Part"
    }
}
