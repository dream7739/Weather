//
//  DateFormatterManager.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

enum DateFormatterManager {
    enum DateFormat: String {
        case apm = "a h시"
        case day = "EEEEE"
    }
        
    static let apmFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.apm.rawValue
        return formatter
    }()
    
    static let dayFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.day.rawValue
        return formatter
    }()
}
