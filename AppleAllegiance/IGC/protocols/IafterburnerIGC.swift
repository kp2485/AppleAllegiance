//
//  IafterburnerIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

protocol IafterburnerIGC: IpartTypeIGC {
    var fuelConsumption: Float { get }
    var maxThrustWithGA: Float { get }
    var maxThrust: Float { get }
    var onRate: Float { get }
    var offRate: Float { get }
    var power: Float { get set }
    var interiorSound: SoundID { get }
    var exteriorSound: SoundID { get }
    var mountedFraction: Float { get set }
    
    func incrementalUpdate(lastUpdate: Time, now: Time, useFuel: Bool)
    func arm()
}
