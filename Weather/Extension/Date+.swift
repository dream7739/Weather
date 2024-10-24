//
//  Date+.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

extension Date {
    var toTimeInterval: Int {
        return Int(self.timeIntervalSince1970)
    }
    
    var dayAfterTomorrow: Date {
        return self.addingTimeInterval(86400 * 2)
    }
    
    var toApmFormat: String {
        return DateFormatterManager.apmFormatter.string(from: self)
    }
}
