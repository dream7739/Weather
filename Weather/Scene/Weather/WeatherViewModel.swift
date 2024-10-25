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
                    let mainWeatherSection = owner.createMainWeather(result: value)
                    let hourWeatherSection = owner.createHourWeather(result: value)
                    let weekWeatherSection = owner.createWeekWeather(result: value)
                    let mapWeatherSection = owner.createMapWeather(result: value)
                    let detailWeatherSection = owner.createDetailWeather(result: value)
                    
                    let sectionModel = [
                        mainWeatherSection,
                        hourWeatherSection,
                        weekWeatherSection,
                        mapWeatherSection,
                        detailWeatherSection
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
    private func createMainWeather(result: WeatherResult) -> WeatherSectionModel {
        let timeList = result.list.map { $0.dt }
        let recentTime = Date().getMostRecentWeather(timeIntervals: timeList)
        let recentWeather = result.list.filter { $0.dt == recentTime }.first

        guard let recentWeather else {
            return WeatherSectionModel.map(items: [])
        }
        
        let city = result.city.name
        let temp = recentWeather.main.temp.toString + "°"
        let description = recentWeather.weather.first?.main ?? ""
        let highTemp = recentWeather.main.temp_max.toString + "°"
        let lowTemp = recentWeather.main.temp_min.toString + "°"
        
        let mainWeather = MainWeather(
            city: city,
            temperature: temp,
            description: description,
            highTemp: highTemp,
            lowTemp: lowTemp
        )
        
        let mainItem = SectionItem.main(
            data: mainWeather
        )
        
        let mainSection = WeatherSectionModel.main(items: [mainItem])
        return mainSection
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
            let weather = Constant.WeatherIcon($0.weather.first?.icon ?? "01d").rawValue
            let temp = $0.main.temp.toString + "°"
            
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
    
    // 5일간의 일기예보
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
            let weather = Constant.WeatherIcon(dayWeatherList.first?.weather.first?.icon ?? "01d").rawValue
            let lowTemp = dayWeatherList
                .map { $0.main.temp_min }
                .min { $0 < $1 } ?? 0
            let highTemp = dayWeatherList
                .map { $0.main.temp_max }
                .max { $0 > $1 } ?? 0
            
            let weekWeather = WeekWeather(
                weekDay: weekDay,
                weather: weather,
                lowTemp: "최소: " + lowTemp.toString + "°",
                highTemp: "최대: " + highTemp.toString + "°"
            )
            
            weekWeatherList.append(weekWeather)
        }
        
        let weekItemList = weekWeatherList.map { SectionItem.week(data: $0) }
        let weekSection = WeatherSectionModel.week(items: weekItemList)
        return weekSection
    }
    
    // 선택 도시 기반 지도
    private func createMapWeather(result: WeatherResult) -> WeatherSectionModel {
        let coord = result.city.coord
        let mapWeather = MapWeather(lat: coord.lat, lon: coord.lon)
        let mapItem = SectionItem.map(data: mapWeather)
        let mapSection = WeatherSectionModel.map(items: [mapItem])
        return mapSection
    }
    
    // 습도, 구름, 바람속도, 기압 등 상세한 일기예보 * 평균값
    private func createDetailWeather(result: WeatherResult) -> WeatherSectionModel {
        let weatherList = result.list
        let listCount = Double(weatherList.count)
        
        // 습도
        let humidityList = weatherList.map { $0.main.humidity }
        let humidityAvg = humidityList.reduce(into: 0) { $0 += $1 } / listCount
        let humidity = humidityAvg.toString + "%"
        let humidityItem = SectionItem.detail(
            data: DetailWeather(
                title: Constant.DetailTitle.humidity.rawValue,
                average: humidity
            )
        )
        
        // 구름
        let cloudList = weatherList.map { $0.clouds.all }
        let cloudAvg = cloudList.reduce(into: 0) { $0 += $1 } / listCount
        let cloud = cloudAvg.toString + "%"
        let cloudItem = SectionItem.detail(
            data: DetailWeather(
                title: Constant.DetailTitle.cloud.rawValue,
                average: cloud
            )
        )
        
        // 바람속도
        let windSpeedList = weatherList.map { $0.wind.speed }
        let windSpeedAvg = windSpeedList.reduce(into: 0) { $0 += $1 } / listCount
        let wind = windSpeedAvg.toStatString + "m/s"
        
        let gustList = weatherList.map { $0.wind.gust }
        let gustAvg = gustList.reduce(into: 0) { $0 += $1 } / listCount
        let gust = "강풍: " + gustAvg.toStatString + "m/s"
        
        let windItem = SectionItem.detail(
            data: DetailWeather(
                title: Constant.DetailTitle.windSpeed.rawValue,
                average: wind,
                description: gust
            )
        )
        
        // 기압
        let pressureList = weatherList.map { $0.main.pressure }
        let pressureAvg = pressureList.reduce(into: 0) { $0 += $1 } / listCount
        let pressure = Int(pressureAvg).formatted(.number) + "\nhpa"
        let pressureItem = SectionItem.detail(
            data: DetailWeather(
                title: Constant.DetailTitle.pressure.rawValue,
                average: pressure
            )
        )
        
        let detailSection = WeatherSectionModel.map(
            items: [
                humidityItem,
                cloudItem,
                windItem,
                pressureItem
            ]
        )
        return detailSection
    }
}
