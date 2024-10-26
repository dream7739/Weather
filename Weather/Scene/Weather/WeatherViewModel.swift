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
        let setBackgroundImage: PublishRelay<Int>
        let sections: BehaviorRelay<[WeatherSectionModel]>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let sections = BehaviorRelay<[WeatherSectionModel]>(value: [])
        let setBackgroundImage = PublishRelay<Int>()
        
        input.callWeatherRequest
            .flatMap { coord in
                NetworkManager.shared.callRequest(coord)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let value):
                    let city = value.city.name
                    let coord = value.city.coord
                    let mainWeather = owner.getMainWeather(result: value)
                    let hourWeather = owner.getHourWeather(result: value)
                    let weekWeather = owner.getWeekWeather(result: value)
                    
                    let weatherCondition = mainWeather?.weather.first?.id ?? 0
                    setBackgroundImage.accept(weatherCondition)
                    
                    let mainWeatherSection = owner.createMainWeather(city, mainWeather)
                    let hourWeatherSection = owner.createHourWeather(hourWeather)
                    let weekWeatherSection = owner.createWeekWeather(weekWeather)
                    let mapWeatherSection = owner.createMapWeather(coord)
                    let detailWeatherSection = owner.createDetailWeather(value)

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
        
        return Output(
            setBackgroundImage: setBackgroundImage,
            sections: sections
        )
    }
}

extension WeatherViewModel {
    private func getMainWeather(result: WeatherResult) -> WeatherInfo? {
        let timeList = result.list.map { $0.dt }
        let recentTime = Date().getMostRecentWeather(timeIntervals: timeList)
        let recentWeather = result.list.filter { $0.dt == recentTime }.first
        return recentWeather
    }
    
    private func getHourWeather(result: WeatherResult) -> [WeatherInfo] {
        let date = Date()
        let dayAfterTomorrow = date.dayAfterTomorrow.toTimeInterval
        let hourWeatherList = result.list.filter {
            $0.dt < dayAfterTomorrow
        }
        return hourWeatherList
    }
    
    private func getWeekWeather(result: WeatherResult) -> [[WeatherInfo]] {
        let date = Date()
        let weekDayList = date.weekDays
        var weekWeatherList: [[WeatherInfo]] = Array(repeating: [], count: 5)
        
        for i in 0..<weekDayList.count {
            let startDate = weekDayList[i]
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? Date()
            let dayWeatherList = result.list.filter {
                $0.dt >= startDate.toTimeInterval &&
                $0.dt < endDate.toTimeInterval
            }
            weekWeatherList[i] = dayWeatherList
        }
        return weekWeatherList
    }
}

extension WeatherViewModel {
    private func createMainWeather(_ city: String, _ weatherInfo: WeatherInfo?) -> WeatherSectionModel {
        guard let weatherInfo else {
            return WeatherSectionModel.map(items: [])
        }
        
        let temp = weatherInfo.main.temp.toString + "°"
        let description = weatherInfo.weather.first?.main ?? ""
        let highTemp = weatherInfo.main.temp_max.toString + "°"
        let lowTemp = weatherInfo.main.temp_min.toString + "°"
        
        let mainWeather = MainWeather(
            city: city,
            temperature: temp,
            description: description,
            highTemp: highTemp,
            lowTemp: lowTemp
        )
        
        let mainItem = SectionItem.main(data: mainWeather)
        let mainSection = WeatherSectionModel.main(items: [mainItem])
        return mainSection
    }
    
    private func createHourWeather(_ hourWeather: [WeatherInfo]) -> WeatherSectionModel {
        let hourWeatherList = hourWeather.enumerated().map { index, value in
            let date = Date(timeIntervalSince1970: TimeInterval(value.dt))
            let hour = index == 0 ? "지금" : date.toApmFormat
            let weather = Constant.WeatherIcon(value.weather.first?.icon ?? "").rawValue
            let temp = value.main.temp.toString + "°"
            
            return HourWeather(
                hour: hour,
                weather: weather,
                temp: temp
            )
        }
        
        let hourItemList = hourWeatherList.map { SectionItem.hour(data: $0) }
        let hourSection = WeatherSectionModel.hour(items: hourItemList)
        return hourSection
    }
    
    private func createWeekWeather(_ weekWeather: [[WeatherInfo]]) -> WeatherSectionModel {
        let date = Date()
        let weekDayList = date.weekDays
        var weekWeatherList: [WeekWeather] = []
        
        for i in 0..<weekWeather.count {
            let weekDate = weekDayList[i]
            let dayWeather = weekWeather[i]
            
            var weekDay: String
            if Calendar.current.startOfDay(for: date) == weekDate {
                weekDay = "오늘"
            } else {
                weekDay = DateFormatterManager.dayFormatter.string(from: weekDayList[i])
            }
            
            let weather = Constant.WeatherIcon(dayWeather.first?.weather.first?.icon ?? "01d").rawValue
            
            let lowTemp = dayWeather
                .map { $0.main.temp_min }
                .min() ?? 0
            let highTemp = dayWeather
                .map { $0.main.temp_max }
                .max() ?? 0
            
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
    
    private func createMapWeather(_ coord: Coord) -> WeatherSectionModel {
        let mapWeather = MapWeather(lat: coord.lat, lon: coord.lon)
        let mapItem = SectionItem.map(data: mapWeather)
        let mapSection = WeatherSectionModel.map(items: [mapItem])
        return mapSection
    }
    
    private func createDetailWeather(_ result: WeatherResult) -> WeatherSectionModel {
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
