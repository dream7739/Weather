//
//  MainWeather.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

struct MainWeather: Hashable, Identifiable {
    let id = UUID()
    let city: String
    let temperature: Int
    let description: String
    let highTemp: Int
    let lowTemp: Int
}