//
//  Constant.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

enum Constant {
    enum WeatherIcon: String {
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
    
    enum WeatherBackgroundImage: String {
        case thunderstorm
        case fog
        case clouds
        case rain
        case snow
        case sunny
        
        init(conditionCode: Int) {
            switch conditionCode {
            case 200..<300:
                self = .thunderstorm
            case 300..<400:
                self = .rain
            case 500..<600:
                self = .rain
            case 600..<700:
                self = .snow
            case 700..<800:
                self = .fog
            case 800:
                self = .sunny
            case 801..<900:
                self = .clouds
            default:
                self = .sunny
            }
        }
    }
    
    enum WeatherDetailTitle: String {
        case humidity = "습도"
        case cloud = "구름"
        case windSpeed = "바람 속도"
        case pressure = "기압"
    }
}
