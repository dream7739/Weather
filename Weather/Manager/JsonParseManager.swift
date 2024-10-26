//
//  JsonParseManager.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import Foundation
import RxSwift


final class JsonParseManager {
    enum JsonParseError: Error {
        case failFileLocation
        case failDataDecoding
    }
    
    static let shared = JsonParseManager()
    private init() { }
    
    func parseJSONFromFile(fileName: String) -> Single<[CityResult]> {
        return Single<[CityResult]>.create { observer in
            guard let url = Bundle.main.url(
                forResource: fileName,
                withExtension: Literal.Json.fileExtension
            ) else {
                observer(.failure(JsonParseError.failFileLocation))
                return Disposables.create()
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let cityList = try decoder.decode([CityResult].self, from: data)
                observer(.success(cityList))
            } catch {
                observer(.failure(JsonParseError.failDataDecoding))
            }
            
            return Disposables.create()
        }
    }
}
