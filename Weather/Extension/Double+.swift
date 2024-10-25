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
}
