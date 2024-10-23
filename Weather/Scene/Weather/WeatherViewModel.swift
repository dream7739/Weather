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
        
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.callWeatherRequest
            .flatMap { coord in
                NetworkManager.shared.callRequest(coord)
            }
        
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output()
    }
}
