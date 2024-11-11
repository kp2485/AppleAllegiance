//
//  IIgcSite.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

protocol IIgcSite: AnyObject {
    func playNotificationSound(_ soundID: SoundID, for ship: IshipIGC)
    func postNotificationText(_ ship: IshipIGC, isExterior: Bool, _ message: String)
    // Add other necessary methods
}
