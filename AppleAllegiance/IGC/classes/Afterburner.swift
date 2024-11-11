//
//  Afterburner.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//

import Foundation

// MARK: - Afterburner Class

class Afterburner: IafterburnerIGC {
    
    // MARK: - Properties
    
    weak var mission: ImissionIGC?
    var data: DataPartTypeIGC?
    var typeData: DataAfterburnerTypeIGC?
    weak var ship: IshipIGC?
    
    var power: Float = 0.0
    var mountedFraction: Float = 0.0
    var mountID: Mount = Constants.mountNA
    var isActive: Bool = false
    
    // MARK: - Initializer
    
    init() {
        // Initializer logic if needed
    }
    
    // MARK: - IpartTypeIGC Protocol Methods
    
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
    
    var fuelConsumption: Float {
        return typeData?.fuelConsumption ?? 0.0
    }
    
    var maxThrustWithGA: Float {
        guard let ship = self.ship, let typeData = self.typeData else { return 0.0 }
        let gaThrust = ship.getSide().getGlobalAttributeSet().getAttribute(.c_gaThrust)
        return typeData.maxThrust * gaThrust
    }
    
    var maxThrust: Float {
        return typeData?.maxThrust ?? 0.0
    }
    
    var onRate: Float {
        return typeData?.onRate ?? 0.0
    }
    
    var offRate: Float {
        return typeData?.offRate ?? 0.0
    }
    
    var interiorSound: SoundID {
        return typeData?.interiorSound ?? 0
    }
    
    var exteriorSound: SoundID {
        return typeData?.exteriorSound ?? 0
    }
    
    var powerValue: Float {
        get { return power }
        set {
            assert(newValue >= 0.0, "Power cannot be negative")
            assert(newValue <= 1.0, "Power cannot exceed 1.0")
            
            if newValue != 0.0 {
                activate()
            }
            
            power = newValue
        }
    }
    
    var mountedFractionValue: Float {
        get { return mountedFraction }
        set {
            mountedFraction = newValue
            if newValue != 1.0 {
                deactivate()
            }
        }
    }
    
    func incrementalUpdate(lastUpdate: Time, now: Time, useFuel: Bool) {
        guard let ship = self.ship,
              let mission = self.mission,
              let typeData = self.typeData else { return }
        
        assert(now >= lastUpdate, "Current time must be greater than or equal to last update time")
        
        let dt = now - lastUpdate
        
        if mountedFraction < 1.0 {
            if useFuel {
                let mountRate = mission.getFloatConstant(.c_fcidMountRate)
                mountedFraction += dt * mountRate
            }
            
            if mountedFraction >= 1.0 {
                // Assuming getIgcSite() returns non-optional IIgcSite
                let igcSite = mission.getIgcSite()
                igcSite.playNotificationSound(typeData.interiorSound, for: ship)
                igcSite.postNotificationText(ship, isExterior: false, "\(getName()) ready.")
                
                mountedFraction = 1.0
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
        
        if isActive {
            if isActivated {
                power += dt * onRate
                if power > 1.0 {
                    power = 1.0
                }
            } else {
                power -= dt * offRate
                if power <= 0.0 {
                    deactivate()
                }
            }
            
            if power != 0.0 && useFuel {
                let fuelUsed = power * fuelConsumption * maxThrust * dt
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
    
    func arm() {
        mountedFraction = 1.0
    }
    
    // MARK: - Initialization and Termination
    
    func initialize(mission: ImissionIGC, now: Time, data: DataPartTypeIGC) throws {
        self.mission = mission
        self.data = data
        
        // Initialize typeData if equipmentType is afterburner
        if data.equipmentType == .afterburner, let afterburnerData = data.afterburnerData {
            self.typeData = afterburnerData
        } else {
            throw InitializationError.invalidEquipmentType
        }
    }
    
    func terminate() {
        // Terminate Afterburner
        setShip(newVal: nil, mount: .na)
        
        // Terminate PartType if needed
        // Since we're no longer using raw pointers or separate PartType instances,
        // handle any necessary cleanup here.
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
        
        assert(mountID == Constants.mountNA, "Mount ID should be NA before setting new ship")
        
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
            self.mountID = newVal
            // If additional mounting logic is needed, implement here
        }
    }
    
    var active: Bool {
        return self.isActive
    }
    
    // MARK: - Activation and Deactivation
    
    private func activate() {
        guard let ship = self.ship, let typeData = self.typeData else { return }
        if !isActive {
            ship.changeSignature(typeData.signature)
            isActive = true
            power = 0.0
        }
    }
    
    private func deactivate() {
        guard let ship = self.ship, let typeData = self.typeData else { return }
        if isActive {
            ship.changeSignature(-typeData.signature)
            isActive = false
            power = 0.0
        }
    }
    
    // MARK: - Errors
    
    enum InitializationError: Error {
        case invalidEquipmentType
        // Add other error cases as needed
    }
}
