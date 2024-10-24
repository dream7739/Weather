//
//  WeatherConstant.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

enum WeatherConstant: String {
    case clearSky = "01d"
    case fewClouds = "02d"
    case scatteredClouds = "03d"
    case brokenClouds = "04d"
    case showerRain = "09d"
    case rain = "10d"
    case thunderstorm = "11d"
    case snow = "13d"
    case mist = "50d"
    
    init(_ iconName: String) {
        switch iconName {
        case "01d", "01n":
            self = .clearSky
        case "02d", "02n":
            self = .fewClouds
        case "03d", "03n":
            self = .scatteredClouds
        case "04d", "04n":
            self = .brokenClouds
        case "09d", "09n":
            self = .showerRain
        case "10d", "10n":
            self = .rain
        case "11d", "11n":
            self = .thunderstorm
        case "13d", "13n":
            self = .snow
        case "50d", "50n":
            self = .mist
        default:
            self = .clearSky
        }
    }
}
