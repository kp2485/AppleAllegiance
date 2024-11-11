//
//  IpartTypeIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

protocol IpartTypeIGC: AnyObject {
    func getData() -> UnsafeRawPointer
    func addRef()
    func release()
    func getName() -> String
    func getEquipmentTypeName(_ et: EquipmentType) -> String
    func terminate()
    // Add other necessary methods
}

