//
//  IpartIGC.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/9/24.
//
        
protocol IpartIGC: AnyObject {
    func getData() -> UnsafeRawPointer
    func addRef()
    func release()
    // Add other necessary methods
}
