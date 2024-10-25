//
//  DetailWeather.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import Foundation

struct DetailWeather {
    let title: String
    let average: String
    let description: String?
    
    init(title: String, average: String, description: String? = nil) {
        self.title = title
        self.average = average
        self.description = description
    }
}
