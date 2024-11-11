//
//  Color.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/10/24.
//

import Foundation

struct Color: Codable {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float
    
    init(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
