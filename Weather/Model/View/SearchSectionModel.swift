//
//  SearchSectionModel.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import RxDataSources

enum SearchSection: Int, CaseIterable {
    case recent
    case city
}

enum SearchSectionModel: SectionModelType {
    typealias Item = SearchSectionItem
    
    case recent(items: [SearchSectionItem])
    case city(items: [SearchSectionItem])
   
    var items: [SearchSectionItem] {
        switch self {
        case .recent(let items):
            return items.map { $0 }
        case .city(let items):
            return items.map { $0 }
     
        }
    }
    
    init(original: SearchSectionModel, items: [SearchSectionItem]) {
        switch original {
        case .recent(let items):
            self = .recent(items: items)
        case .city(let items):
            self = .city(items: items)
      
        }
    }
}

enum SearchSectionItem {
    case recent(data: String)
    case city(data: CityResult)
}

