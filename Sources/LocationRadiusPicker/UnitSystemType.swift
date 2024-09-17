//
//  UnitSystemType.swift
//  
//
//  Created by Eman Basic on 16.09.24.
//

import Foundation

/// Enum representing the unit system type.
public enum UnitSystemType {
    /// The metric system (meters, kilometres, etc.).
    case metric
    
    /// The imperial system (feet, miles, etc.).
    case imperial
    
    /// The system type determined by the user's device settings.
    case system

    /// Automatically determines the appropriate unit system based on the current locale.
    static var current: UnitSystemType {
        if #available(iOS 16, *) {
            Locale.current.measurementSystem == .metric ? .metric : .imperial
        } else {
            Locale.current.usesMetricSystem ? .metric : .imperial
        }
    }
}

fileprivate extension Locale {
    /// Property to determine if the locale uses the metric system.
    var usesMetricSystem: Bool {
        (self as NSLocale).object(forKey: .measurementSystem) as? String == "Metric"
    }
}
