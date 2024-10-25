//
//  CityResult.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import Foundation

struct CityResult: Decodable {
    let id: Int
    let name: String
    let country: String
    let coord: Coord
}
