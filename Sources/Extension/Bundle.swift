//
//  Bundle.swift
//  ShoppableTests
//
//  Created by Ouamassi Brahim on 19/02/2024.
//

import Foundation
/// Extension to Bundle to retrieve the application name.
extension Bundle {
    /// Computed property to get the application name from the bundle.
    var applicationName: String? {
        // Check if CFBundleDisplayName exists in the Info.plist.
        if let displayName: String = self.infoDictionary?["CFBundleDisplayName"] as? String {
            return displayName
            // If CFBundleDisplayName doesn't exist, check for CFBundleName.
        } else if let name: String = self.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        // If neither CFBundleDisplayName nor CFBundleName is available, return nil
        return nil
    }
}
