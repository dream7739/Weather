//
//  HourWeather.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import Foundation

struct HourWeather: Hashable, Identifiable {
    let id = UUID()
    let hour: String
    let weather: String
    let temp: String
}
