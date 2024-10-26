//
//  UserDefaultsManager.swift
//  Weather
//
//  Created by 홍정민 on 10/27/24.
//

import Foundation

struct RecentSearch: Codable {
    let name: String
    let coord: Coord
    let saveDate: Date
}

@propertyWrapper
struct UserDefaultsManager<T: Codable> {
    let defaultValue: T
    let key: String
    let storage: UserDefaults
    
    var wrappedValue: T {
        get {
            if let data = storage.data(forKey: key) {
                let decoder = JSONDecoder()
                if let decodedValue = try? decoder.decode(T.self, from: data) {
                    return decodedValue
                }
            }
            return defaultValue
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                storage.set(encoded, forKey: key)
            }
        }
    }
}

final class UserManager {
    private init() { }
    
    @UserDefaultsManager(
        defaultValue: [:],
        key: "recentList",
        storage: .standard
    )
    static var recentList: [Int: RecentSearch]
    
    
}
