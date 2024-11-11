//
//  IshipIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

protocol IshipIGC: AnyObject {
    func getLastUpdate() -> Time
    func deletePart(_ part: IpartIGC)
    func addPart(_ part: IpartIGC)
    func mountPart(_ part: IpartIGC, _ mount: Mount, _ currentMountID: inout Mount)
    func getFuel() -> Float
    func setFuel(_ fuel: Float)
    func changeSignature(_ signature: Float)
    func getStateM() -> Int
    func getSide() -> ISideIGC
    // Add other necessary methods
}
