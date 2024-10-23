//
//  WeekWeather.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import Foundation

struct WeekWeather: Hashable, Identifiable {
    let id = UUID()
    let weekDay: String
    let weather: String
    let lowTemp: String
    let highTemp: String
}
