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
        let searchResultUpdator: PublishRelay<String>
        let saveRecentSearch: PublishRelay<CityResult>
    }
    
    struct Output {
        let presentError: PublishRelay<String>
        let sections: BehaviorRelay<[SearchSectionModel]>
    }
    
    var cityList: [CityResult] = []
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let presentError = PublishRelay<String>()
        let sections = BehaviorRelay<[SearchSectionModel]>(value: [])
        
        input.jsonParseRequest
            .flatMap { fileName in
                JsonParseManager.shared.parseJSONFromFile(fileName: fileName)
                    .catch { error in
                        return Single.never()
                    }
            }
            .subscribe(with: self) { owner, cityList in
                owner.cityList = cityList
            }
            .disposed(by: disposeBag)
        
        input.searchResultUpdator
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .bind(with: self) { owner, searchText in
                if owner.cityList.isEmpty {
                    presentError.accept(Literal.Message.json)
                } else {
                    let recentSection = owner.createRecentSection()
                    let citySection = owner.createCitySection(searchText)
                    let section = [recentSection, citySection]
                    sections.accept(section)
                }
            }
            .disposed(by: disposeBag)
        
        input.saveRecentSearch
            .bind(with: self) { owner, item in
                UserManager.shared.addRecent(
                    RecentSearch(
                        id: item.id,
                        name: item.name,
                        coord: item.coord,
                        saveDate: Date())
                )
                
                if UserManager.shared.isExceedCountLimit() {
                    UserManager.shared.removeOldest()
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            presentError: presentError,
            sections: sections
        )
    }
    
}

extension CitySearchViewModel {
    private func createRecentSection() -> SearchSectionModel {
        let recentList = UserManager.shared.getRecentList()
        let recentItem = recentList.map { SearchSectionItem.recent(data: $0.value) }
        let recentSection = SearchSectionModel.recent(items: recentItem)
        return recentSection
    }
    
    private func createCitySection(_ searchText: String) -> SearchSectionModel {
        var filteredCityList: [CityResult] = []
        if searchText.isEmpty {
            filteredCityList = cityList
        } else {
            filteredCityList = cityList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        let cityItem = filteredCityList.map { SearchSectionItem.city(data: $0) }
        let citySection = SearchSectionModel.city(items: cityItem)
        return citySection
    }
}
