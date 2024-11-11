//
//  ImissionIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

protocol ImissionIGC: AnyObject {
    func getPartType(_ partID: Int) -> IpartTypeIGC?
    func addPartType(_ partType: IpartTypeIGC)
    func deletePartType(_ partType: IpartTypeIGC)
    func getFloatConstant(_ constant: FloatConstant) -> Float
    func getIgcSite() -> IIgcSite
    // Add other necessary methods
}
