//
//  IIgcSite.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

/// Protocol representing the IGC site in the game.
protocol IIgcSite: AnyObject {
    func playNotificationSound(_ soundID: SoundID, for ship: IshipIGC?)
    func postNotificationText(_ ship: IshipIGC?, isExterior: Bool, _ text: String)
    func clientTime(from serverTime: Time) -> Time
}
