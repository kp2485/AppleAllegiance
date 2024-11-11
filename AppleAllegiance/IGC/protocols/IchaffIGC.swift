//
//  IchaffIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/10/24.
//

import Foundation

/// Protocol representing the Chaff component in the game.
protocol IchaffIGC: IpartTypeIGC {
    // Chaff-specific properties
    var lifespan: Float { get }
    var radius: Float { get set }
    var textureName: String { get }
    var interiorSound: SoundID { get }
    var exteriorSound: SoundID { get }
    var timeExpire: Time { get set }
    
    // Operational properties
    var power: Float { get set }
    var mountedFraction: Float { get set }
    
    // Chaff-specific methods
    func incrementalUpdate(lastUpdate: Time, now: Time, useFuel: Bool)
    func arm()
}
