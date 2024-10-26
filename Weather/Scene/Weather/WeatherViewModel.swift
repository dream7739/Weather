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
        let presentError: BehaviorRelay<String>
        let setBackgroundImage: PublishRelay<Int>
        let sections: BehaviorRelay<[WeatherSectionModel]>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let presentError = BehaviorRelay<String>(value: "")
        let sections = BehaviorRelay<[WeatherSectionModel]>(value: [])
        let setBackgroundImage = PublishRelay<Int>()
        
        input.callWeatherRequest
            .map { coord in
                let request = WeatherRequest(lat: coord.lat, lon: coord.lon)
                let urlRequest = try? WeatherRouter.forecast(request: request).asURLRequest()
                return urlRequest
            }
            .flatMap { urlRequest in
                if let urlRequest {
                    return NetworkManager.shared.callRequest(
                        request: urlRequest,
                        response: WeatherResult.self
                    )
                } else {
                    presentError.accept(Literal.Message.network)
                    return Single<Result<WeatherResult, Error>>.never()
                }
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let value):
                    let coord = value.city.coord
                    
                    let correntWeather = owner.configureCurrentWeather(value)
                    if let correntWeather {
                        let weatherCondition = correntWeather.weather.first?.id ?? 0
                        setBackgroundImage.accept(weatherCondition)
                    }

                    let mainWeatherSection = owner.createMainWeather(value)
                    let hourWeatherSection = owner.createHourWeather(value)
                    let weekWeatherSection = owner.createWeekWeather(value)
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
                case .failure:
                    presentError.accept(Literal.Message.network)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            presentError: presentError,
            setBackgroundImage: setBackgroundImage,
            sections: sections
        )
    }
}

extension WeatherViewModel {
    private func configureCurrentWeather(_ result: WeatherResult) -> WeatherInfo? {
        let currentTime = Date().toTimeInterval
        let weatherInfo = result.list.min {
            abs($0.dt - currentTime) < abs($1.dt - currentTime)
        }
        return weatherInfo
    }
    
    private func createMainWeather(_ result: WeatherResult) -> WeatherSectionModel {
        let weatherInfo = configureCurrentWeather(result)
        guard let weatherInfo else { return WeatherSectionModel.main(items: []) }
        
        let city = result.city.name
        let temp = weatherInfo.main.tempDescription
        let description = weatherInfo.weather.first?.description ?? ""
        let highTemp = weatherInfo.main.maxTempDescription
        let lowTemp = weatherInfo.main.minTempDescription
        
        let mainWeather = MainWeather(
            city: city,
            temperature: temp,
            description: description,
            maxTemp: highTemp,
            minTemp: lowTemp
        )
        
        let mainItem = WeatherSectionItem.main(data: mainWeather)
        let mainSection = WeatherSectionModel.main(items: [mainItem])
        return mainSection
    }
    
    private func createHourWeather(_ result: WeatherResult) -> WeatherSectionModel {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 2, to: today) ?? Date()
        let hourWeather = result.list.filter { $0.dt < tomorrow.toTimeInterval }
        
        let hourWeatherList = hourWeather.enumerated().map { index, value in
            let date = Date(timeIntervalSince1970: TimeInterval(value.dt))
            let hour = index == 0 ? Literal.Weather.now : date.toApmTimeFormat
            let weather = Constant.WeatherIcon(value.weather.first?.icon ?? "").rawValue
            let temp = value.main.temp.toTempString
            
            return HourWeather(
                hour: hour,
                weather: weather,
                temp: temp
            )
        }
        
        var header: String
        if let weatherInfo = hourWeather.first {
            header = createRandomHeader(weatherInfo)
        } else {
            header = Literal.WeatherTitle.hourWeather.rawValue
        }
        
        let hourItemList = hourWeatherList.map { WeatherSectionItem.hour(data: $0) }
        let hourSection = WeatherSectionModel.hour(header: header, items: hourItemList)
        return hourSection
    }
    
    private func createRandomHeader(_ info: WeatherInfo) -> String {
        let gust = info.wind.gust.toSpeedString
        let humidity = info.main.humidity.toPercentString
        let weather = info.weather.first?.description ?? ""
        let temp = info.main.temp.toTempString
        let feelsLike = info.main.feels_like.toTempString
        
        let gustString = Literal.RandomHeader.gust(gust: gust).title
        let humidityString = Literal.RandomHeader.humidity(humidity: humidity).title
        let weatherString = Literal.RandomHeader.weather(
            weather: weather,
            temp: temp,
            feelsLike: feelsLike
        ).title
        
        let header = [gustString, humidityString, weatherString].randomElement()!
        return header
    }
    
    private func createWeekWeather(_ result: WeatherResult) -> WeatherSectionModel {
        let date = Date()
        let weekDayList = date.weekDayList
        var weekWeatherList: [WeekWeather] = []
        
        for i in 0..<weekDayList.count {
            let startDate = weekDayList[i]
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? Date()
            let dayWeatherList = result.list.filter {
                $0.dt >= startDate.toTimeInterval &&
                $0.dt < endDate.toTimeInterval
            }
            
            var weekDay: String
            if i == 0 {
                weekDay = Literal.Weather.today
            } else {
                weekDay = DateFormatterManager.dayFormatter.string(from: startDate)
            }
            
            let weather = Constant.WeatherIcon(
                dayWeatherList.first?.weather.first?.icon ?? ""
            ).rawValue
            
            let minTemp = dayWeatherList
                .map { $0.main.temp_min }
                .min() ?? 0
            let minTempDescription = Literal.Weather.minTemp + minTemp.toTempString
            
            let maxTemp = dayWeatherList
                .map { $0.main.temp_max }
                .max() ?? 0
            let maxTempDescription = Literal.Weather.maxTemp + maxTemp.toTempString
            
            let weekWeather = WeekWeather(
                weekDay: weekDay,
                weather: weather,
                maxTemp: maxTempDescription,
                minTemp: minTempDescription
            )
            
            weekWeatherList.append(weekWeather)
        }
        
        let header = Literal.WeatherTitle.weekWeather.rawValue
        let weekItemList = weekWeatherList.map { WeatherSectionItem.week(data: $0) }
        let weekSection = WeatherSectionModel.week(header: header, items: weekItemList)
        return weekSection
    }
    
    private func createMapWeather(_ coord: Coord) -> WeatherSectionModel {
        let mapWeather = MapWeather(lat: coord.lat, lon: coord.lon)
        let mapItem = WeatherSectionItem.map(data: mapWeather)
        let header = Literal.WeatherTitle.mapWeather.rawValue
        let mapSection = WeatherSectionModel.map(header: header, items: [mapItem])
        return mapSection
    }
    
    private func createDetailWeather(_ result: WeatherResult) -> WeatherSectionModel {
        let weatherList = result.list
        let listCount = Double(weatherList.count)
        
        let humidityList = weatherList.map { $0.main.humidity }
        let humidityAvg = humidityList.reduce(into: 0) { $0 += $1 } / listCount
        let humidity = humidityAvg.toPercentString
        let humidityItem = WeatherSectionItem.detail(
            data: DetailWeather(
                title: Literal.WeatherTitle.humidity.rawValue,
                average: humidity
            )
        )
        
        let cloudList = weatherList.map { $0.clouds.all }
        let cloudAvg = cloudList.reduce(into: 0) { $0 += $1 } / listCount
        let cloud = cloudAvg.toPercentString
        let cloudItem = WeatherSectionItem.detail(
            data: DetailWeather(
                title: Literal.WeatherTitle.cloud.rawValue,
                average: cloud
            )
        )
        
        let windSpeedList = weatherList.map { $0.wind.speed }
        let windSpeedAvg = windSpeedList.reduce(into: 0) { $0 += $1 } / listCount
        let wind = windSpeedAvg.toSpeedString
        
        let gustList = weatherList.map { $0.wind.gust }
        let gustAvg = gustList.reduce(into: 0) { $0 += $1 } / listCount
        let gust = Literal.Weather.gust + gustAvg.toSpeedString
        
        let windItem = WeatherSectionItem.detail(
            data: DetailWeather(
                title: Literal.WeatherTitle.windSpeed.rawValue,
                average: wind,
                description: gust
            )
        )
        
        let pressureList = weatherList.map { $0.main.pressure }
        let pressureAvg = pressureList.reduce(into: 0) { $0 += $1 } / listCount
        let pressure = Int(pressureAvg).formatted(.number) + "\n" + Literal.Weather.hpa
        let pressureItem = WeatherSectionItem.detail(
            data: DetailWeather(
                title: Literal.WeatherTitle.pressure.rawValue,
                average: pressure
            )
        )
        
        let detailSection = WeatherSectionModel.detail(
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
