//
//  DateFormatterManager.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

enum DateFormatterManager {
    static let locale = "ko_KR"
    
    enum DateFormat: String {
        case apm = "a h시"
        case day = "EEEEE"
    }
        
    static let apmFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.apm.rawValue
        formatter.locale = Locale(identifier: DateFormatterManager.locale)
        return formatter
    }()
    
    static let dayFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.day.rawValue
        formatter.locale = Locale(identifier: DateFormatterManager.locale)
        return formatter
    }()
}
