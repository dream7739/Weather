//
//  NetworkManager.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import Foundation
import Alamofire
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private init() { }
    
    func callRequest(_ coord: Coord) -> Single<Result<WeatherResult, Error>> {
        let url = APIURL.forecast + "?lat=\(coord.lat)&lon=\(coord.lon)&appid=\(APIKey.weather)"
        let result = Single<Result<WeatherResult, Error>>.create { observer in
            AF.request(url)
                .validate(statusCode: 200...400)
                .responseDecodable(of: WeatherResult.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer(.success(.success(value)))
                    case .failure(let error):
                        observer(.success(.failure(error)))
                    }
                }
            return Disposables.create()
        }
        
        return result
    }
}
