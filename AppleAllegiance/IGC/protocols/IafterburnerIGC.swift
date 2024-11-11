//
//  IafterburnerIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

protocol IafterburnerIGC: IpartTypeIGC {
    func getFuelConsumption() -> Float
    func getMaxThrustWithGA() -> Float
    func getMaxThrust() -> Float
    func getOnRate() -> Float
    func getOffRate() -> Float
    func getPower() -> Float
    func setPower(_ p: Float)
    func incrementalUpdate(lastUpdate: Time, now: Time, useFuel: Bool)
    func getInteriorSound() -> SoundID
    func getExteriorSound() -> SoundID
    func getMountedFraction() -> Float
    func setMountedFraction(_ f: Float)
    func arm()
}
