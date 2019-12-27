//
//  CodableStoreNotificationCenter.swift
//  CodableStoreKit
//
//  Created by Sven Tiigi on 21.11.19.
//  Copyright © 2019 Sven Tiigi. All rights reserved.
//

import Foundation

// MARK: - CodableStoreNotificationCenter

/// The CodableStoreNotificationCenter
open class CodableStoreNotificationCenter {
    
    // MARK: Static Properties
    
    /// The default shared instance of CodableStoreNotificationCenter
    public static let `default` = CodableStoreNotificationCenter()
    
    // MARK: Properties
    
    /// The Observations
    var observations: [(Any) -> Bool] = .init()
    
    // MARK: Initializer
    
    /// Designated Initializer
    public init() {}
    
    // MARK: Observe
    
    /// Observe all ChangeEvents to any CodableStore
    /// - Parameters:
    ///   - object: The Object to observe on
    ///   - observer: The Observer
    open func observeAll<Object: AnyObject>(
        on object: Object,
        observer: @escaping () -> Void
    ) {
        // Append Observation
        self.observations.append { [weak object] _ in
            // Verify Object is still available
            guard object != nil else {
                // Object isn't available return false
                // To indicate that the observation can be removed
                return false
            }
            // Invoke Observer
            observer()
            // Return true
            return true
        }
    }
    
    /// Observe CodableStore ChangeEvent
    /// - Parameters:
    ///   - object: The Object to observe on
    ///   - observer: The Observer
    open func observe<Object: AnyObject, Storable: CodableStorable>(
        on object: Object,
        _ observer: @escaping (CodableStore<Storable>.ChangeEvent) -> Void
    ) {
        // Append Observation
        self.observations.append { [weak object] changeEvent in
            // Verify Object is still available
            guard object != nil else {
                // Object isn't available return false
                // To indicate that the observation can be removed
                return false
            }
            // Verify ChangeEvent matches the Storable type
            guard let changeEvent = changeEvent as? CodableStore<Storable>.ChangeEvent else {
                // Otherwise return true as the Storable type
                // doesn't match the current one
                return true
            }
            // Invoke Observer with ChangeEvent
            observer(changeEvent)
            // Return true
            return true
        }
    }
    
    // MARK: Emit
    
    /// Emit CodableStore  ChangeEvent
    /// - Parameter changeEvent: The CodableStore  ChangeEvent that should be emitted
    open func emit<Storable: CodableStorable>(_ changeEvent: CodableStore<Storable>.ChangeEvent) {
        // Invoke observations and filter out any deallocated observer
         self.observations = self.observations.filter { $0(changeEvent) }
    }
    
}