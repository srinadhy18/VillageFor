//
//  UserDefaults.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//

import Foundation

/// This extension adds custom, type-safe properties to UserDefaults for managing app-specific settings.
extension UserDefaults {
    
    // A private enum to hold the keys, preventing typos.
    private enum Keys {
        static let shouldShowEPDSIntroduction = "shouldShowEPDSIntroduction"
    }
    
    /// A property to get or set the preference for showing the EPDS intro screen.
    /// It defaults to `true` if no value has been set before.
    var shouldShowEPDSIntroduction: Bool {
        get {
            // If the key doesn't exist, it's the first time the app is run,
            // so we should show the introduction.
            if object(forKey: Keys.shouldShowEPDSIntroduction) == nil {
                return true
            }
            // Otherwise, return the saved boolean value.
            return bool(forKey: Keys.shouldShowEPDSIntroduction)
        }
        set {
            // Saves the new value to UserDefaults.
            set(newValue, forKey: Keys.shouldShowEPDSIntroduction)
        }
    }
}

