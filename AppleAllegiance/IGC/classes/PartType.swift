//
//  PartType.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

// MARK: - PartType Class

class PartType: IpartTypeIGC {
    
    // MARK: - Properties
    
    weak var mission: ImissionIGC?
    var data: DataPartTypeIGC?
    private var pptSuccessor: IpartTypeIGC?
    
    // MARK: - Initializer
    
    init() {
        // Initializer logic if needed
    }
    
    // MARK: - IpartIGC Protocol Methods
    
    func getName() -> String {
        return getEquipmentTypeName(data?.equipmentType ?? .afterburner)
    }
    
    func getEquipmentTypeName(_ et: EquipmentType) -> String {
        switch et {
        case .chaffLauncher:
            return "chaff"
        case .weapon:
            return "weapon"
        case .magazine:
            return "missile"
        case .dispenser:
            return "mine"
        case .shield:
            return "shield"
        case .cloak:
            return "cloak"
        case .pack:
            return "ammo"
        case .afterburner:
            return "afterburner"
        }
    }
    
    // MARK: - IpartTypeIGC Protocol Methods
    
    // The 'data' property is now accessible directly; no need for getData()
    
    // MARK: - Initialization and Termination
    
    func initialize(mission: ImissionIGC, now: Time, data: DataPartTypeIGC) throws {
        self.mission = mission
        self.data = data
        
        let successorID = data.successorPartID
        if successorID != Constants.NA {
            guard let successor = mission.getPartType(successorID) else {
                throw InitializationError.invalidSuccessorPartType
            }
            self.pptSuccessor = successor
        }
        
        mission.addPartType(self)
    }
    
    func terminate() {
        guard let mission = self.mission else { return }
        mission.deletePartType(self)
    }
    
    // MARK: - Errors
    
    enum InitializationError: Error {
        case invalidSuccessorPartType
        // Add other error cases as needed
    }
}
