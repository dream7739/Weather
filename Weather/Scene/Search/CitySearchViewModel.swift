//
//  CitySearchViewModel.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CitySearchViewModel: BaseViewModel {
    struct Input {
        let jsonParseRequest: BehaviorRelay<String>
    }
    
    struct Output {
        let sections: BehaviorRelay<[SearchSectionModel]>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let sections = BehaviorRelay<[SearchSectionModel]>(value: [])
        
        input.jsonParseRequest
            .flatMap { fileName in
                JsonParseManager.shared.parseJSONFromFile(fileName: fileName)
                    .catch { error in
                        return Single.never()
                    }
            }
            .subscribe(with: self) { owner, cityList in
                let recentItem = Set<String>().map { SearchSectionItem.recent(data: $0) }
                let cityItem = cityList.map { SearchSectionItem.city(data: $0) }
                let recentSection = SearchSectionModel.recent(items: recentItem)
                let citySection = SearchSectionModel.city(items: cityItem)
                let section = [recentSection, citySection]
                sections.accept(section)
            }
            .disposed(by: disposeBag)
        
        
        return Output(sections: sections)
    }
    
}

extension CitySearchViewModel {
    
}
