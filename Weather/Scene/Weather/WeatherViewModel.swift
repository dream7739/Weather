//
//  WeatherViewModel.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class WeatherViewModel: BaseViewModel {
    struct Input {
        let callWeatherRequest: BehaviorRelay<Coord>
    }
    
    struct Output {
        let sections: BehaviorRelay<[WeatherSectionModel]>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let sections = BehaviorRelay<[WeatherSectionModel]>(value: [])

        input.callWeatherRequest
            .flatMap { coord in
                NetworkManager.shared.callRequest(coord)
            }
            .subscribe(with: self) {
                owner,
                result in
                switch result {
                case .success(let value):
                    print(value)
                    let mainWeather = owner.createMainWeather(result: value)
                    let hourWeather = owner.createHourWeather(result: value)
                    let weekWeather = owner.createWeekWeather(result: value)
                    let mapWeather = owner.createMapWeather(result: value)
                    let detailWeather = owner.createDetailWeather(result: value)
                    
                    let mainSection = WeatherSectionModel.main(items: [.main(data: mainWeather)])
                    let hourSection = WeatherSectionModel.hour(items: [.hour(data: hourWeather)])
                    let weekSection = WeatherSectionModel.week(items: [.week(data: weekWeather)])
                    let mapSection = WeatherSectionModel.map(items: [.map(data: mapWeather)])
                    let detailSection = WeatherSectionModel.map(items: [.detail(data: detailWeather)])
                    let sectionModel = [
                        mainSection,
                        hourSection,
                        weekSection,
                        mapSection,
                        detailSection
                    ]
                    sections.accept(sectionModel)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)

        return Output(sections: sections)
    }
}

extension WeatherViewModel {
    private func createMainWeather(result: WeatherResult) -> MainWeather {
        return MainWeather(
            city: "Seoul",
            temperature: 30,
            description: "맑음",
            highTemp: 30,
            lowTemp: 10
        )
    }
    
    private func createHourWeather(result: WeatherResult) -> HourWeather {
        return HourWeather(
            hour: "12",
            weather: "10d",
            temp: "30"
        )
    }
    
    private func createWeekWeather(result: WeatherResult) -> WeekWeather {
        return WeekWeather(
            weekDay: "월",
            weather: "10d",
            lowTemp: "10",
            highTemp: "30"
        )
    }
    
    private func createMapWeather(result: WeatherResult) -> MapWeather {
        return MapWeather(
            lat: 36.783611,
            lon: 127.004173
        )
    }
    
    private func createDetailWeather(result: WeatherResult) -> DetailWeather {
        return DetailWeather(
            title: "바람",
            average: "30",
            description: nil
        )
    }
}
