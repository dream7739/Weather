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
            .map {
                let request = WeatherRequest(lat: $0.lat, lon: $0.lon)
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
            return WeatherSectionModel.main(items: [])
        }
        
        let temp = weatherInfo.main.temp.toString + "°"
        let description = weatherInfo.weather.first?.description ?? ""
        let highTemp = weatherInfo.main.temp_max.toString + "°"
        let lowTemp = weatherInfo.main.temp_min.toString + "°"
        
        let mainWeather = MainWeather(
            city: city,
            temperature: temp,
            description: description,
            highTemp: highTemp,
            lowTemp: lowTemp
        )
        
        let mainItem = WeatherSectionItem.main(data: mainWeather)
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
        
        var header = ""
        if let nowWeather = hourWeather.first {
            header = createRandomHeader(nowWeather: nowWeather)
        }
        
        let hourItemList = hourWeatherList.map { WeatherSectionItem.hour(data: $0) }
        let hourSection = WeatherSectionModel.hour(header: header, items: hourItemList)
        return hourSection
    }
    
    private func createRandomHeader(nowWeather: WeatherInfo) -> String {
        let gust = nowWeather.wind.gust.toStatString + "m/s"
        let humidity = nowWeather.main.humidity.toString + "%"
        let weather = nowWeather.weather.first?.description ?? ""
        let temp = nowWeather.main.temp.toString + "°"
        let feelsLike = nowWeather.main.feels_like.toString + "°"
        
        let gustString = "돌풍의 풍속은 최대 \(gust)입니다"
        let humidityString = "현재 습도는 \(humidity)입니다"
        let weatherString = "현재 날씨는 \(weather)입니다.\n현재 기온은 \(temp)이며 체감 기온은 \(feelsLike)입니다"
        
        let header = [
            gustString,
            humidityString,
            weatherString
        ].randomElement() ?? "시간별 날씨예보"
        
        return header
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
        
        let header = "5일간의 일기예보"
        let weekItemList = weekWeatherList.map { WeatherSectionItem.week(data: $0) }
        let weekSection = WeatherSectionModel.week(header: header, items: weekItemList)
        return weekSection
    }
    
    private func createMapWeather(_ coord: Coord) -> WeatherSectionModel {
        let mapWeather = MapWeather(lat: coord.lat, lon: coord.lon)
        let mapItem = WeatherSectionItem.map(data: mapWeather)
        let header = "강수량"
        let mapSection = WeatherSectionModel.map(header: header, items: [mapItem])
        return mapSection
    }
    
    private func createDetailWeather(_ result: WeatherResult) -> WeatherSectionModel {
        let weatherList = result.list
        let listCount = Double(weatherList.count)
        
        // 습도
        let humidityList = weatherList.map { $0.main.humidity }
        let humidityAvg = humidityList.reduce(into: 0) { $0 += $1 } / listCount
        let humidity = humidityAvg.toString + "%"
        let humidityItem = WeatherSectionItem.detail(
            data: DetailWeather(
                title: Constant.DetailTitle.humidity.rawValue,
                average: humidity
            )
        )
        
        // 구름
        let cloudList = weatherList.map { $0.clouds.all }
        let cloudAvg = cloudList.reduce(into: 0) { $0 += $1 } / listCount
        let cloud = cloudAvg.toString + "%"
        let cloudItem = WeatherSectionItem.detail(
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
        
        let windItem = WeatherSectionItem.detail(
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
        let pressureItem = WeatherSectionItem.detail(
            data: DetailWeather(
                title: Constant.DetailTitle.pressure.rawValue,
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
