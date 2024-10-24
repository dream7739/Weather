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
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let value):
                    let mainWeather = owner.createMainWeather(result: value)
                    let hourWeatherSection = owner.createHourWeather(result: value)
                    let weekWeatherSection = owner.createWeekWeather(result: value)
                    let mapWeatherSection = owner.createMapWeather(result: value)
                    let detailWeather = owner.createDetailWeather(result: value)
                    
                    let mainSection = WeatherSectionModel.main(items: [.main(data: mainWeather)])
                    let detailSection = WeatherSectionModel.map(items: [.detail(data: detailWeather)])
                    
                    let sectionModel = [
                        mainSection,
                        hourWeatherSection,
                        weekWeatherSection,
                        mapWeatherSection,
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
    // 메인 날씨
    private func createMainWeather(result: WeatherResult) -> MainWeather {
        
        return MainWeather(
            city: "Seoul",
            temperature: 30,
            description: "맑음",
            highTemp: 30,
            lowTemp: 10
        )
    }
    
    // 3시간 간격의 일기예보
    private func createHourWeather(result: WeatherResult) -> WeatherSectionModel {
        let date = Date()
        let current = date.toTimeInterval
        let dayAfterTomorrow = date.dayAfterTomorrow.toTimeInterval
        let hourWeatherList = result.list.filter {
            $0.dt >= current && $0.dt < dayAfterTomorrow
        }
        
        let hourItemList = hourWeatherList.map {
            let date = Date(timeIntervalSinceReferenceDate: TimeInterval($0.dt))
            let hour = date.toApmFormat
            let weather = WeatherConstant($0.weather.first?.icon ?? "01d").rawValue
            let temp = $0.main.temp.toTmpFormat
            
            return SectionItem.hour(
                data: HourWeather(
                    hour: hour,
                    weather: weather,
                    temp: temp
                )
            )
        }
        
        let hourSection = WeatherSectionModel.hour(items: hourItemList)
        return hourSection
    }
    
    //5일간의 일기예보
    private func createWeekWeather(result: WeatherResult) -> WeatherSectionModel {
        let date = Date()
        let weekDayList = date.weekDays
        var weekWeatherList: [WeekWeather] = []

        for i in 0..<weekDayList.count - 1 {
            let dayWeatherList = result.list.filter {
                $0.dt >= weekDayList[i].toTimeInterval &&
                $0.dt < weekDayList[i+1].toTimeInterval
            }
            
            let weekDate = weekDayList[i]
            var weekDay: String
            if Calendar.current.startOfDay(for: date) == weekDate {
                weekDay = "오늘"
            } else {
                weekDay = DateFormatterManager.dayFormatter.string(from: weekDayList[i])
            }
            let weather = WeatherConstant(dayWeatherList.first?.weather.first?.icon ?? "01d").rawValue
            let lowTemp = dayWeatherList
                .map { $0.main.temp_min }
                .min { $0 < $1 } ?? 0
            let highTemp = dayWeatherList
                .map { $0.main.temp_max }
                .max { $0 > $1 } ?? 0
            
            let weekWeather = WeekWeather(
                weekDay: weekDay,
                weather: weather,
                lowTemp: "최소: " + lowTemp.toTmpFormat,
                highTemp: "최대: " + highTemp.toTmpFormat
            )
            
            weekWeatherList.append(weekWeather)
        }
        
        let weekItemList = weekWeatherList.map { SectionItem.week(data: $0) }
        let weekSection = WeatherSectionModel.week(items: weekItemList)
        return weekSection
    }
    
    private func createMapWeather(result: WeatherResult) -> WeatherSectionModel {
        let coord = result.city.coord
        let mapWeather = MapWeather(lat: coord.lat, lon: coord.lon)
        let mapItem = SectionItem.map(data: mapWeather)
        let mapSection = WeatherSectionModel.map(items: [mapItem])
        return mapSection
    }
    
    private func createDetailWeather(result: WeatherResult) -> DetailWeather {
        return DetailWeather(
            title: "바람",
            average: "30",
            description: nil
        )
    }
}
