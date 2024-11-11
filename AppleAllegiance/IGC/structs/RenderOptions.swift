//
//  RenderOptions.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/10/24.
//

import Foundation

struct RenderOptions: OptionSet, Codable {
    let rawValue: Int
    
    static let notPickable = RenderOptions(rawValue: 1 << 0)
    static let predictable = RenderOptions(rawValue: 1 << 1)
    
    // Add other rendering options as needed.
}
