//
//  IpartTypeIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

protocol IpartTypeIGC: IpartIGC {
    var data: DataPartTypeIGC? { get }
    func getEquipmentTypeName(_ et: EquipmentType) -> String
    func terminate()
    // Add other necessary methods
}


