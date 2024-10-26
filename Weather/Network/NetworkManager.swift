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
    
    func callRequest<T: Decodable>(
        request: URLRequest,
        response: T.Type
    ) -> Single<Result<T, Error>> {
        let result = Single<Result<T, Error>>.create { observer in
            AF.request(request)
                .validate(statusCode: 200...400)
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer(.success(.success(value)))
                    case .failure(let error):
                        print(error)
                        observer(.success(.failure(error)))
                    }
                }
            return Disposables.create()
        }
        
        return result
    }
}
