//
//  Double+.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

extension Double {
    var toString: String {
        return String(format: "%.f", self)
    }
    
    var toStatString: String {
        return String(format: "%.2f", self)
    }
    
//    var toPercentFormat: String {
//        return toString + "%"
//    }
//    
//    var toTempFormat: String {
//        return toString + "°"
//    }
//    
//    var toSpeedFormat: String {
//        return toStatString + "m/s"
//    }
//    
//    var toPressureFormat: String {
//        let pressure = Int(self)
//        return pressure.formatted() + "\nhpa"
//    }
}
