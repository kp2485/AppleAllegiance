//
//  ChaffDataIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/10/24.
//

import Foundation

/// Protocol containing all necessary data for initializing a Chaff instance.
protocol ChaffDataIGC {
    // Properties from DataChaffTypeIGC
    var lifespan: Float { get }
    var radius: Float { get }
    var textureName: String { get }
    var interiorSound: SoundID { get }
    var exteriorSound: SoundID { get }
    var signature: Float { get }
    
    // Properties from DataChaffIGC
    var p0: Vector3 { get }
    var v0: Vector3 { get }
    var pcluster: IclusterIGC? { get }
    var time0: Time { get }
}

/// Struct containing all Chaff data required for initialization.
struct ChaffDataIGCImpl: ChaffDataIGC, Codable {
    // DataChaffTypeIGC properties
    let lifespan: Float
    let radius: Float
    let textureName: String
    let interiorSound: SoundID
    let exteriorSound: SoundID
    let signature: Float
    
    // DataChaffIGC properties
    let p0: Vector3
    let v0: Vector3
    let pcluster: IclusterIGC?
    let time0: Time
    
    // CodingKeys to exclude pcluster from Codable
    enum CodingKeys: String, CodingKey {
        case lifespan
        case radius
        case textureName
        case interiorSound
        case exteriorSound
        case signature
        case p0
        case v0
        case time0
        // pcluster is excluded
    }
    
    // Custom initializer to handle exclusion of pcluster during decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lifespan = try container.decode(Float.self, forKey: .lifespan)
        radius = try container.decode(Float.self, forKey: .radius)
        textureName = try container.decode(String.self, forKey: .textureName)
        interiorSound = try container.decode(SoundID.self, forKey: .interiorSound)
        exteriorSound = try container.decode(SoundID.self, forKey: .exteriorSound)
        signature = try container.decode(Float.self, forKey: .signature)
        p0 = try container.decode(Vector3.self, forKey: .p0)
        v0 = try container.decode(Vector3.self, forKey: .v0)
        time0 = try container.decode(Time.self, forKey: .time0)
        pcluster = nil // Not decoded
    }
    
    // Custom encoder to exclude pcluster during encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lifespan, forKey: .lifespan)
        try container.encode(radius, forKey: .radius)
        try container.encode(textureName, forKey: .textureName)
        try container.encode(interiorSound, forKey: .interiorSound)
        try container.encode(exteriorSound, forKey: .exteriorSound)
        try container.encode(signature, forKey: .signature)
        try container.encode(p0, forKey: .p0)
        try container.encode(v0, forKey: .v0)
        try container.encode(time0, forKey: .time0)
        // pcluster is not encoded
    }
    
    // Convenience initializer for manual initialization
    init(lifespan: Float, radius: Float, textureName: String, interiorSound: SoundID, exteriorSound: SoundID, signature: Float, p0: Vector3, v0: Vector3, pcluster: IclusterIGC?, time0: Time) {
        self.lifespan = lifespan
        self.radius = radius
        self.textureName = textureName
        self.interiorSound = interiorSound
        self.exteriorSound = exteriorSound
        self.signature = signature
        self.p0 = p0
        self.v0 = v0
        self.pcluster = pcluster
        self.time0 = time0
    }
}
