//
//  WeatherResult.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import Foundation

struct WeatherResult: Decodable {
    let cod: String
    let list: [WeatherInfo]
    let city: CityInfo
}

struct WeatherInfo: Decodable {
    let dt: Int
    let main: MainInfo
    let weather: [Weather]
    let clouds: Cloud
    let dt_txt: String
}

struct MainInfo: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Double
    let pressure: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Cloud: Decodable {
    let all: Int
}

struct CityInfo: Decodable {
    let id: Int
    let name: String
    let coord: Coord
}

struct Wind: Decodable {
    let speed: Double
}

struct City: Decodable {
    let id: Int
    let name: String
    let state: String
    let country: String
    let coord: Coord
}

struct Coord: Decodable {
    let lat: Double
    let lon: Double
}
