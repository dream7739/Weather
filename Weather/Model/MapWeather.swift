//
//  MapWeather.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import Foundation

struct MapWeather: Hashable, Identifiable {
    let id = UUID()
    let lat: Double
    let lon: Double
}
