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
    
    var toTempString: String {
        return self.toString + "°"
    }
    
    var toSpeedString: String {
        return self.toStatString + "m/s"
    }
    
    var toPercentString: String {
        return self.toString + "%"
    }
}
