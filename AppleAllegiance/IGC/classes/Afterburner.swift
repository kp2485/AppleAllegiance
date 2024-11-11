//
//  Afterburner.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

// Afterburner.swift

import Foundation

// MARK: - Afterburner Class

class Afterburner: IafterburnerIGC, IpartIGC {
    
    // MARK: - Properties
    
    private weak var mission: ImissionIGC?
    private var typeData: DataAfterburnerTypeIGC?
    private var partType: IpartTypeIGC?
    private weak var ship: IshipIGC?
    
    private var power: Float = 0.0
    private var mountedFraction: Float = 0.0
    private var mountID: Mount = Constants.mountNA
    private var isActive: Bool = false
    
    // Reference counting properties
    private var referenceCount: Int = 1
    
    // MARK: - Initializer
    
    init() {
        self.partType = nil
        self.ship = nil
        self.isActive = false
        self.power = 0.0
        self.mountID = Constants.mountNA
    }
    
    // MARK: - IpartTypeIGC Protocol Methods
    
    func getData() -> UnsafeRawPointer {
        guard let typeData = self.typeData else {
            fatalError("DataAfterburnerTypeIGC is not initialized.")
        }
        return withUnsafePointer(to: &self.typeData!) {
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
        return "Afterburner" // Or derive from partType.getName()
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
    
    // MARK: - IafterburnerIGC Protocol Methods
    
    func getFuelConsumption() -> Float {
        return self.typeData?.fuelConsumption ?? 0.0
    }
    
    func getMaxThrustWithGA() -> Float {
        guard let ship = self.ship, let typeData = self.typeData else { return 0.0 }
        let gaThrust = ship.getSide().getGlobalAttributeSet().getAttribute(.c_gaThrust)
        return typeData.maxThrust * gaThrust
    }
    
    func getMaxThrust() -> Float {
        return self.typeData?.maxThrust ?? 0.0
    }
    
    func getOnRate() -> Float {
        return self.typeData?.onRate ?? 0.0
    }
    
    func getOffRate() -> Float {
        return self.typeData?.offRate ?? 0.0
    }
    
    func getPower() -> Float {
        return self.power
    }
    
    func setPower(_ p: Float) {
        assert(p >= 0.0, "Power cannot be negative")
        assert(p <= 1.0, "Power cannot exceed 1.0")
        
        if p != 0.0 {
            activate()
        }
        
        self.power = p
    }
    
    func incrementalUpdate(lastUpdate: Time, now: Time, useFuel: Bool) {
        guard let ship = self.ship, let mission = self.mission, let typeData = self.typeData else { return }
        assert(now >= lastUpdate, "Current time must be greater than or equal to last update time")
        
        let dt = now - lastUpdate
        
        if self.mountedFraction < 1.0 {
            if useFuel {
                let mountRate = mission.getFloatConstant(.c_fcidMountRate)
                self.mountedFraction += dt * mountRate
            }
            
            if self.mountedFraction >= 1.0 {
                if let igcSite: IIgcSite? = mission.getIgcSite() {
                    igcSite?.playNotificationSound(typeData.interiorSound, for: ship)
                    igcSite?.postNotificationText(ship, isExterior: false, "\(partType?.getName() ?? "Afterburner") ready.")
                }
                self.mountedFraction = 1.0
            } else {
                return
            }
        }
        
        let fuel = ship.getFuel()
        let isAfterburnerButtonPressed = (ship.getStateM() & Constants.afterburnerButtonIGC) != 0
        let isActivated = isAfterburnerButtonPressed && (fuel != 0.0)
        
        if isActivated {
            activate()
        }
        
        if self.isActive {
            if isActivated {
                self.power += dt * (typeData.onRate)
                if self.power > 1.0 {
                    self.power = 1.0
                }
            } else {
                self.power -= dt * (typeData.offRate)
                if self.power <= 0.0 {
                    deactivate()
                }
            }
            
            if self.power != 0.0 && useFuel {
                let fuelUsed = self.power * typeData.fuelConsumption * typeData.maxThrust * dt
                if fuelUsed < fuel {
                    ship.setFuel(fuel - fuelUsed)
                } else if fuel != 0.0 {
                    // Out of gas
                    ship.setFuel(0.0)
                    deactivate()
                }
            }
        }
    }
    
    func getInteriorSound() -> SoundID {
        return self.typeData?.interiorSound ?? 0
    }
    
    func getExteriorSound() -> SoundID {
        return self.typeData?.exteriorSound ?? 0
    }
    
    func getMountedFraction() -> Float {
        return self.mountedFraction
    }
    
    func setMountedFraction(_ f: Float) {
        self.mountedFraction = f
        if f != 1.0 {
            deactivate()
        }
    }
    
    func arm() {
        self.mountedFraction = 1.0
    }
    
    // MARK: - Initialization and Termination
    
    func initialize(mission: ImissionIGC, now: Time, data: UnsafeMutableRawPointer, dataSize: Int) throws {
        self.mission = mission
        
        // Initialize PartType
        let partType = PartType()
        try partType.initialize(mission: mission, now: now, data: data, dataSize: dataSize)
        self.partType = partType
        
        // Proceed with Afterburner initialization using partType
        // Bind DataAfterburnerTypeIGC from partType's data
        let dataPtr = partType.getData().assumingMemoryBound(to: DataAfterburnerTypeIGC.self)
        self.typeData = dataPtr.pointee
    }
    
    func terminate() {
        // Terminate Afterburner
        setShip(newVal: nil, mount: .na)
        
        // Terminate PartType
        self.partType?.terminate()
        self.partType = nil
    }
    
    func update(now: Time) {
        guard let ship = self.ship else { return }
        let lastUpdate = ship.getLastUpdate()
        incrementalUpdate(lastUpdate: lastUpdate, now: now, useFuel: true)
    }
    
    // MARK: - Ship Management
    
    func setShip(newVal: IshipIGC?, mount: Mount) {
        // Ensure part is not deleted during the operation
        if let currentShip = self.ship {
            currentShip.deletePart(self)
            // No need to release in Swift
        }
        
        assert(self.mountID == .na, "Mount ID should be NA before setting new ship")
        
        self.ship = newVal
        
        if let newShip = self.ship {
            newShip.addPart(self)
            setMountID(newVal: mount)
        }
    }
    
    var currentMountID: Mount {
        return self.mountID
    }
    
    func setMountID(newVal: Mount) {
        assert(self.ship != nil, "Ship must be set before setting mount ID")
        
        if newVal != self.mountID {
            deactivate()
            var currentMount = self.mountID
            self.ship?.mountPart(self, newVal, &currentMount)
            self.mountID = currentMount
        }
    }
    
    var active: Bool {
        return self.isActive
    }
    
    // MARK: - Activation and Deactivation
    
    private func activate() {
        guard let ship = self.ship, let typeData = self.typeData else { return }
        if !self.isActive {
            ship.changeSignature(typeData.signature)
            self.isActive = true
            self.power = 0.0
        }
    }
    
    private func deactivate() {
        guard let ship = self.ship, let typeData = self.typeData else { return }
        if self.isActive {
            ship.changeSignature(-typeData.signature)
            self.isActive = false
            self.power = 0.0
        }
    }
}
