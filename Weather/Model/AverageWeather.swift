//
//  AverageWeather.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import Foundation

struct AverageWeather: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let average: String
}
