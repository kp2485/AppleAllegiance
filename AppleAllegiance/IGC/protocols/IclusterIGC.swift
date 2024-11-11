//
//  IclusterIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

/// Protocol representing a cluster in the game.
protocol IclusterIGC: AnyObject {
    func addModel(_ model: IpartIGC)
    func deleteModel(_ model: IpartIGC)
}
