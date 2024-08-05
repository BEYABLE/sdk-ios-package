//
//  DataStorageHelper.swift
//
//
//  Created by Ouamassi Brahim on 27/01/2024.
//

import Foundation
///  A class that manages the saving of certain data in the shared preferences of the phone
class DataStorageHelper {
    
    static func setData<T>(value: T, key: UserDefaultKeys) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }
    static func getData<T>(type: T.Type, forKey: UserDefaultKeys) -> T? {
        let defaults = UserDefaults.standard
        let value = defaults.object(forKey: forKey.rawValue) as? T
        return value
    }
    static func removeData(key: UserDefaultKeys) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key.rawValue)
    }
    
    /// Retrieve an object from previously saved preferences.
    /// - Parameter forKey
    /// - Returns: the object
    static func getObjectFromDataString <U>(forKey: UserDefaultKeys) -> U? where U: Codable{
        let displayProcessJsonString = DataStorageHelper.getData(type: String.self, forKey: forKey)
        
        guard let jsonData = displayProcessJsonString?.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        let displayProcessObject = try? decoder.decode(U.self, from: jsonData)
        return displayProcessObject
    }
    
    
    /// This function saves object into the preference, before save it, it convert it to a string json and save it
    /// - Parameters:
    ///   - data: object to save
    ///   - type: type of the object
    ///   - forKey
    static func setObjectPref <U>(data: U , type: U.Type, forKey: UserDefaultKeys) where U: Codable{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(data)
        guard let data = data else {
            return
        }
        let dataString = String(data: data, encoding: .utf8)
        DataStorageHelper.setData(value: dataString, key: forKey)
        
    }
    
    /// Return String json from data
    /// - Parameter data: convert this object to String json
    /// - Returns: String json
    static func getStringJsonFromObject<U>(data: U)->String where U: Codable{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(data)
        guard let data = data else {
            return "{}"
        }
        let dataString = String(data: data, encoding: .utf8)
        return dataString ?? "{}"
    }
}

///  List of keys that will be used to store data in the preferences.
enum UserDefaultKeys: String, CaseIterable {
    case apiKey
    case showLog
    case sessionToken
    case crossSessionToken
    case trackingId
    case uniqueId
    case sessionId
    case displayProcess
}
