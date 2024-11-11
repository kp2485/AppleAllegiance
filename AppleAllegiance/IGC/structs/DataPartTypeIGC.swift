//
//  DataPartTypeIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

struct DataPartTypeIGC {
    let equipmentType: EquipmentType
    let successorPartID: Int // Use Constants.NA if not applicable
    let afterburnerData: DataAfterburnerTypeIGC?
    let chaffData: ChaffDataIGC?
    // Add other necessary properties
}
