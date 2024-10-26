//
//  WeatherRouter.swift
//  Weather
//
//  Created by 홍정민 on 10/26/24.
//

import Foundation
import Alamofire

enum WeatherRouter {
    case forecast(request: WeatherRequest)
}

extension WeatherRouter: TargetType {
    var baseURL: String {
        return APIURL.forecast
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .forecast:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .forecast:
            return "forecast"
        }
    }
    
    var header: [String : String] {
        return [:]
    }
    
    var parameters: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .forecast(let request):
            return [
                URLQueryItem(name: QueryParam.lat.rawValue, value: "\(request.lat)"),
                URLQueryItem(name: QueryParam.lon.rawValue, value: "\(request.lon)"),
                URLQueryItem(name: QueryParam.units.rawValue, value: request.units),
                URLQueryItem(name: QueryParam.lang.rawValue, value: request.lang),
                URLQueryItem(name: QueryParam.appid.rawValue, value: APIKey.weather)
            ]
        }
    }
    
    var body: Data? {
        return nil
    }
    
}
