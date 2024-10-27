//
//  Literal.swift
//  Weather
//
//  Created by 홍정민 on 10/26/24.
//

import Foundation

enum Literal {
    enum Placeholder {
        static let search = "Search"
    }
    
    enum Message {
        static let disabled = "네트워크가 연결되어있지 않습니다"
        static let network = "오류가 발생하였습니다"
        static let json = "도시 정보를 가져올 수 없습니다"
        static let emptyResult = "검색 결과가 없습니다"
    }
    
    enum Json {
        static let fileExtension = "json"
        static let fileName = "reduced_citylist"
    }
    
    enum InitialCoord {
        static let lat = 36.783611
        static let lon = 127.004173
    }
    
    enum Weather {
        static let now = "지금"
        static let today = "오늘"
        static let maxTemp = "최대: "
        static let minTemp = "최소: "
        static let gust = "강풍: "
        static let hpa = "hpa"
    }
    
    enum WeatherTitle: String {
        case hourWeather = "시간별 날씨예보"
        case weekWeather = "5일간의 일기예보"
        case mapWeather = "강수량"
        case humidity = "습도"
        case cloud = "구름"
        case windSpeed = "바람 속도"
        case pressure = "기압"
    }
    
    enum RandomHeader {
        case gust(gust: String)
        case humidity(humidity: String)
        case weather(weather: String, temp: String, feelsLike: String)
 
        var title: String {
            switch self {
            case .gust(let gust):
                return "돌풍의 풍속은 최대 \(gust)입니다."
            case .humidity(let humidity):
                return "현재 습도는 \(humidity)입니다."
            case .weather(let weather, let temp, let feelsLike):
                return "현재 날씨는 \(weather)입니다.\n현재 기온은 \(temp)이며 체감 기온은 \(feelsLike)입니다."
            }
        }
    }
}
