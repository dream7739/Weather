//
//  JsonParseManager.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import Foundation
import RxSwift

enum JsonParseError: Error, LocalizedError {
    case failFileLocation
    case failDataDecoding
    
    var errorDescription: String? {
        switch self {
        case .failFileLocation:
            return "파일을 찾을 수 없습니다."
        case .failDataDecoding:
            return "데이터 디코딩에 실패하였습니다."
        }
    }
}

final class JsonParseManager {
    static let shared = JsonParseManager()
    private init() { }
    
    func parseJSONFromFile(fileName: String) -> Single<[City]> {
        return Single.create { observer in
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                observer.onError(JsonParseError.failFileLocation)
                return Disposables.create()
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let cityList = try decoder.decode([City].self, from: data)
                observer.onNext(cityList)
            } catch {
                observer.onError(JsonParseError.failDataDecoding)
            }
            
            return Disposables.create()
        }
    }
}
