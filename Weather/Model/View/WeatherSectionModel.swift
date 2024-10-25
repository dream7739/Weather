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
    typealias Item = SectionItem
    
    case main(items: [SectionItem])
    case hour(items: [SectionItem])
    case week(items: [SectionItem])
    case map(items: [SectionItem])
    case detail(items: [SectionItem])
    
    var items: [SectionItem] {
        switch self {
        case .main(let items):
            return items.map { $0 }
        case .hour(let items):
            return items.map { $0 }
        case .week(items: let items):
            return items.map { $0 }
        case .map(let items):
            return items.map { $0 }
        case .detail(let items):
            return items.map { $0 }
        }
    }
    
    init(original: WeatherSectionModel, items: [SectionItem]) {
        switch original {
        case .main(let items):
            self = .main(items: items)
        case .hour(let items):
            self = .hour(items: items)
        case .week(let items):
            self = .week(items: items)
        case .map(let items):
            self = .map(items: items)
        case .detail(let items):
            self = .detail(items: items)
        }
    }
}

enum SectionItem {
    case main(data: MainWeather)
    case hour(data: HourWeather)
    case week(data: WeekWeather)
    case map(data: MapWeather)
    case detail(data: DetailWeather)
}
