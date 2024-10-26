//
//  MainWeather.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

struct MainWeather {
    let city: String
    let temperature: String
    let description: String
    let maxTemp: String
    let minTemp: String
    
    var tempDescription: String {
        return "최고: \(maxTemp) | 최저: \(minTemp)"
    }
}
