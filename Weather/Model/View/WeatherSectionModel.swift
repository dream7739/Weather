//
//  WeatherSectionModel.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import RxDataSources

enum WeatherSection: Int, CaseIterable {
    case main
    case hour
    case week
    case map
    case detail
}

enum WeatherSectionModel: SectionModelType {
    typealias Item = WeatherSectionItem
    
    case main(items: [WeatherSectionItem])
    case hour(header: String, items: [WeatherSectionItem])
    case week(header: String, items: [WeatherSectionItem])
    case map(header: String, items: [WeatherSectionItem])
    case detail(items: [WeatherSectionItem])
    
    var items: [WeatherSectionItem] {
        switch self {
        case .main(let items), .hour(_, let items), .week(_, let items),
                .map(_, let items), .detail(let items):
            return items
        }
    }
    
    init(original: WeatherSectionModel, items: [WeatherSectionItem]) {
        switch original {
        case .main(let items):
            self = .main(items: items)
        case .hour(let header, let items):
            self = .hour(header: header, items: items)
        case .week(let header, let items):
            self = .week(header: header, items: items)
        case .map(let header, let items):
            self = .map(header: header, items: items)
        case .detail(let items):
            self = .detail(items: items)
        }
    }
}

enum WeatherSectionItem {
    case main(data: MainWeather)
    case hour(data: HourWeather)
    case week(data: WeekWeather)
    case map(data: MapWeather)
    case detail(data: DetailWeather)
}
