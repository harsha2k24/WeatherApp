//
//  StringAddditions.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation

extension String {
    /// Returns the localized string for the current key.
    /// - Returns: The localized string.
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
