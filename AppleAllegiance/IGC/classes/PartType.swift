//
//  PartType.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

// PartType.swift

import Foundation

// MARK: - PartType Class

class PartType: IpartTypeIGC {
    
    // MARK: - Properties
    
    private weak var mission: ImissionIGC?
    private var dataSize: Int = 0
    private var data: DataPartTypeIGC?
    private var pptSuccessor: IpartTypeIGC?
    
    // Reference counting properties
    private var referenceCount: Int = 1
    
    // MARK: - Initializer
    
    init() {
        // Initializer logic if needed
    }
    
    // MARK: - IpartTypeIGC Protocol Methods
    
    func getData() -> UnsafeRawPointer {
        guard let data = self.data else {
            fatalError("DataPartTypeIGC is not initialized.")
        }
        return withUnsafePointer(to: &self.data!) {
            UnsafeRawPointer($0)
        }
    }
    
    func addRef() {
        referenceCount += 1
    }
    
    func release() {
        referenceCount -= 1
        if referenceCount <= 0 {
            // Perform cleanup if necessary
            // In Swift, ARC handles memory, so no explicit deallocation
        }
    }
    
    func getName() -> String {
        return getEquipmentTypeName(self.data?.equipmentType ?? .afterburner)
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
    
    // MARK: - Initialization and Termination
    
    func initialize(mission: ImissionIGC, now: Time, data: UnsafeMutableRawPointer, dataSize: Int) throws {
        assert(mission != nil, "Mission cannot be nil")
        self.mission = mission
        
        guard dataSize >= MemoryLayout<DataPartTypeIGC>.size else {
            throw InitializationError.invalidDataSize
        }
        
        self.dataSize = dataSize
        // Allocate and copy the DataPartTypeIGC data
        self.data = data.assumingMemoryBound(to: DataPartTypeIGC.self).pointee
        
        if self.data?.successorPartID != Constants.NA {
            if let successor = mission.getPartType(self.data!.successorPartID) {
                self.pptSuccessor = successor
                assert(self.pptSuccessor != nil, "Successor PartType should not be nil")
            } else {
                assertionFailure("Failed to get successor PartType")
            }
        }
        
        mission.addPartType(self)
    }
    
    func terminate() {
        guard let mission = self.mission else { return }
        mission.deletePartType(self)
    }
    
    // MARK: - Export Method
    
    func exportData(to dataPointer: UnsafeMutableRawPointer?) -> Int {
        if let dataPointer = dataPointer, var data = self.data {
            memcpy(dataPointer, &data, self.dataSize)
        }
        return self.dataSize
    }
    
    // MARK: - Errors
    
    enum InitializationError: Error {
        case invalidDataSize
        // Add other error cases as needed
    }
}
