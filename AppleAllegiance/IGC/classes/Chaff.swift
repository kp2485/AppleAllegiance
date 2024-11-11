//
//  Chaff.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/10/24.
//

import Foundation

// MARK: - Chaff Class

/// Class representing the Chaff component in the game.
class Chaff: IchaffIGC {
    
    // MARK: - Properties
    
    weak var mission: ImissionIGC?
    var data: DataPartTypeIGC?
    var chaffData: ChaffDataIGC?
    weak var ship: IshipIGC?
    
    var power: Float = 0.0
    var mountedFraction: Float = 0.0
    var mountID: Mount = Constants.mountNA
    var isActive: Bool = false
    
    var timeExpire: Time = 0.0
    var radius: Float = 0.0
    var lifespan: Float = 0.0
    var textureName: String = ""
    var interiorSound: SoundID = 0
    var exteriorSound: SoundID = 0
    var signature: Float = 0.0
    
    // MARK: - Initializer
    
    init() {
        // Initializer logic if needed
    }
    
    // MARK: - IpartIGC Protocol Methods
    
    /// Returns the name of the Chaff part.
    func getName() -> String {
        return "Chaff"
    }
    
    /// Returns the equipment type name based on the provided EquipmentType.
    ///
    /// - Parameter et: The equipment type.
    /// - Returns: The name of the equipment type as a string.
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
    
    // MARK: - IchaffIGC Protocol Methods
    
    var radiusValue: Float {
        get { return radius }
        set { radius = newValue }
    }
    
    var textureNameValue: String {
        return textureName
    }
    
    var interiorSoundValue: SoundID {
        return interiorSound
    }
    
    var exteriorSoundValue: SoundID {
        return exteriorSound
    }
    
    // MARK: - Operational Properties
    
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
    
    /// Performs an incremental update of the Chaff's state.
    ///
    /// - Parameters:
    ///   - lastUpdate: The time of the last update.
    ///   - now: The current time.
    ///   - useFuel: A flag indicating whether fuel consumption should be considered.
    func incrementalUpdate(lastUpdate: Time, now: Time, useFuel: Bool) {
        guard let ship = self.ship,
              let mission = self.mission,
              let chaffData = self.chaffData else { return }
        
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
                igcSite.playNotificationSound(chaffData.interiorSound, for: ship)
                igcSite.postNotificationText(ship, isExterior: false, "\(getName()) ready.")
                
                mountedFraction = 1.0
            } else {
                return
            }
        }
        
        // Chaff does not consume fuel or have thrust, so these sections are omitted.
        // If Chaff has additional behaviors, implement them here.
    }
    
    /// Arms the Chaff, setting the mounted fraction to complete.
    func arm() {
        mountedFraction = 1.0
    }
    
    // MARK: - Initialization and Termination
    
    /// Initializes the Chaff instance with mission data.
    ///
    /// - Parameters:
    ///   - mission: The current mission context.
    ///   - now: The current time.
    ///   - data: The initialization data for the Chaff.
    /// - Throws: `InitializationError.invalidChaffData` if Chaff data is invalid.
    func initialize(mission: ImissionIGC, now: Time, data: DataPartTypeIGC) throws {
        self.mission = mission
        self.data = data
        
        guard data.equipmentType == .chaffLauncher,
              let chaffData = data.chaffData else {
            throw InitializationError.invalidChaffData
        }
        
        self.chaffData = chaffData
        
        // Assign Chaff-specific properties
        self.lifespan = chaffData.lifespan
        self.radius = chaffData.radius
        self.textureName = chaffData.textureName
        self.interiorSound = chaffData.interiorSound
        self.exteriorSound = chaffData.exteriorSound
        self.signature = chaffData.signature
        
        // Load Decal equivalent
        loadDecal(textureName: chaffData.textureName,
                  color: Color(1.0, 1.0, 1.0, 1.0),
                  isPickable: false,
                  scale: 1.0,
                  renderOptions: [.notPickable, .predictable])
        
        // Set radius to 1.0
        setRadius(1.0)
        
        // Calculate time0 in client time
        let time0 = mission.getIgcSite().clientTime(from: chaffData.time0)
        
        // Set position: p0 + (now - time0) * v0
        let position = chaffData.p0 + (now - time0) * chaffData.v0
        setPosition(position)
        
        // Set velocity
        setVelocity(chaffData.v0)
        
        // Set rotation
        let rotation = Rotation(axis: Vector3(x: 0.0, y: 0.0, z: 1.0), angle: 2.75)
        setRotation(rotation)
        
        // Set mass to 0.0
        setMass(0.0)
        
        // Set timeExpire
        self.timeExpire = time0 + chaffData.lifespan
        
        // Set cluster
        setCluster(chaffData.pcluster)
    }
    
    /// Terminates the Chaff instance.
    func terminate() {
        // Terminate Chaff
        setShip(newVal: nil, mount: .na)
        
        // Additional cleanup if necessary
    }
    
    /// Updates the Chaff state based on the current time.
    ///
    /// - Parameter now: The current time.
    func update(now: Time) {
        guard let ship = self.ship else { return }
        let lastUpdate = ship.getLastUpdate()
        incrementalUpdate(lastUpdate: lastUpdate, now: now, useFuel: true)
    }
    
    // MARK: - Ship Management
    
    /// Sets the ship associated with this Chaff.
    ///
    /// - Parameters:
    ///   - newVal: The new ship to associate.
    ///   - mount: The mount location.
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
    
    /// Returns the current mount ID.
    var currentMountID: Mount {
        return self.mountID
    }
    
    /// Sets the mount ID.
    ///
    /// - Parameter newVal: The new mount location.
    func setMountID(newVal: Mount) {
        assert(self.ship != nil, "Ship must be set before setting mount ID")
        
        if newVal != self.mountID {
            deactivate()
            self.mountID = newVal
            // If additional mounting logic is needed, implement here
        }
    }
    
    /// Indicates whether the Chaff is active.
    var active: Bool {
        return self.isActive
    }
    
    // MARK: - Activation and Deactivation
    
    /// Activates the Chaff.
    private func activate() {
        guard let ship = self.ship,
              let chaffData = self.chaffData else { return }
        if !isActive {
            ship.changeSignature(chaffData.signature)
            isActive = true
            power = 0.0
        }
    }
    
    /// Deactivates the Chaff.
    private func deactivate() {
        guard let ship = self.ship,
              let chaffData = self.chaffData else { return }
        if isActive {
            ship.changeSignature(-chaffData.signature)
            isActive = false
            power = 0.0
        }
    }
    
    // MARK: - Helper Methods
    
    /// Loads the decal for the Chaff.
    ///
    /// - Parameters:
    ///   - textureName: The name of the texture.
    ///   - color: The color to apply.
    ///   - isPickable: Whether the decal is pickable.
    ///   - scale: The scale of the decal.
    ///   - renderOptions: Rendering options for the decal.
    private func loadDecal(textureName: String,
                          color: Color,
                          isPickable: Bool,
                          scale: Float,
                          renderOptions: RenderOptions) {
        // Implement the LoadDecal equivalent in Swift.
        // This is a placeholder for the actual decal loading logic.
        // Example:
        // decal = Decal(textureName: textureName, color: color, isPickable: isPickable, scale: scale, renderOptions: renderOptions)
    }
    
    /// Sets the radius of the Chaff.
    ///
    /// - Parameter radius: The new radius value.
    private func setRadius(_ radius: Float) {
        // Implement setting the radius.
        // Example:
        // self.radius = radius
    }
    
    /// Sets the position of the Chaff.
    ///
    /// - Parameter position: The new position.
    private func setPosition(_ position: Vector3) {
        // Implement setting the position.
        // Example:
        // self.position = position
    }
    
    /// Sets the velocity of the Chaff.
    ///
    /// - Parameter velocity: The new velocity.
    private func setVelocity(_ velocity: Vector3) {
        // Implement setting the velocity.
        // Example:
        // self.velocity = velocity
    }
    
    /// Sets the rotation of the Chaff.
    ///
    /// - Parameter rotation: The new rotation.
    private func setRotation(_ rotation: Rotation) {
        // Implement setting the rotation.
        // Example:
        // self.rotation = rotation
    }
    
    /// Sets the mass of the Chaff.
    ///
    /// - Parameter mass: The new mass value.
    private func setMass(_ mass: Float) {
        // Implement setting the mass.
        // Example:
        // self.mass = mass
    }
    
    /// Sets the cluster of the Chaff.
    ///
    /// - Parameter cluster: The new cluster.
    private func setCluster(_ cluster: IclusterIGC?) {
        // Implement setting the cluster.
        // Example:
        // self.cluster = cluster
    }
    
    // MARK: - Errors
    
    /// Enum representing initialization errors for Chaff.
    enum InitializationError: Error, LocalizedError {
        case invalidChaffData
        
        var errorDescription: String? {
            switch self {
            case .invalidChaffData:
                return "Invalid Chaff data provided during initialization."
            }
        }
    }
}
