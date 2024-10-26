//
//  Date+.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

extension Date {
    var toTimeInterval: TimeInterval {
        return self.timeIntervalSince1970
    }
    
    var toApmTimeFormat: String {
        return DateFormatterManager.apmFormatter.string(from: self)
    }
    
    var weekDayList: [Date] {
        var weekDayList: [Date] = []
        let today = Calendar.current.startOfDay(for: self)
        weekDayList.append(today)
        
        for i in 1...4 {
            let weekDay = Calendar.current.date(byAdding: .day, value: i, to: today) ?? Date()
            weekDayList.append(weekDay)
        }
        
        return weekDayList
    }
}
