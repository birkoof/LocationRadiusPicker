//
//  LocationSearchHistoryManager.swift
//
//
//  Created by Eman Basic on 28.09.24.
//

import Foundation
import UIKit
import MapKit

struct LocationSearchHistoryManager {
    
    // MARK: - Helper structures
    
    enum Keys {
        static let keyRecentLocations = "kRecentLocations"
        static let name = "kName"
        static let address = "kAddress"
        static let latitude = "kLatitude"
        static let longitude = "kLongitude"
    }
    
    // MARK: - Public methods
    
    func history() -> [LocationModel] {
        let history = UserDefaults.standard.object(forKey: Keys.keyRecentLocations) as? [NSDictionary] ?? []
        return history.compactMap(LocationModel.fromHistoryDictionary)
    }
    
    func addToHistory(_ location: LocationModel) {
        guard let dict = location.toHistoryDictionary() else { return }
        
        var history = UserDefaults.standard.object(forKey: Keys.keyRecentLocations) as? [NSDictionary] ?? []
        let historyNames = history.compactMap { $0[Keys.address] as? String }
        
        let alreadyInHistory = historyNames.contains { $0 == location.address }
        if !alreadyInHistory {
            history.insert(dict, at: 0)
            UserDefaults.standard.set(history, forKey: Keys.keyRecentLocations)
        }
    }
    
    func remove(_ location: LocationModel) {
        var history = history()
        history.removeAll { $0 == location }
        UserDefaults.standard.set(history.compactMap { $0.toHistoryDictionary() }, forKey: Keys.keyRecentLocations)
    }
}

// MARK: - Extension over Location

fileprivate extension LocationModel {
    private typealias Keys = LocationSearchHistoryManager.Keys
    
    func toHistoryDictionary() -> NSDictionary? {
        let dict: [String: AnyObject?] = [
            Keys.name: name as AnyObject,
            Keys.address: address as AnyObject,
            Keys.longitude: coordinates.longitude as AnyObject,
            Keys.latitude: coordinates.latitude as AnyObject
        ]
        
        return dict as NSDictionary?
    }
    
    static func fromHistoryDictionary(_ dict: NSDictionary) -> LocationModel? {
        guard let name = dict[Keys.name] as? String,
              let address = dict[Keys.address] as? String,
              let longitude = dict[Keys.longitude] as? Double,
              let latitude = dict[Keys.latitude] as? Double
        else {
            return nil
        }
        
        return LocationModel(
            name: name,
            address: address,
            coordinates: LocationCoordinates(latitude: latitude, longitude: longitude)
        )
    }
}
