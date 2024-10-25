//
//  CitySearchViewModel.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CitySearchViewModel: BaseViewModel {
    struct Input {
        let jsonParseRequest: BehaviorRelay<String>
    }
    
    struct Output {
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.jsonParseRequest
            .flatMap { fileName in
                JsonParseManager.shared.parseJSONFromFile(fileName: fileName)
                    .catch { error in
                        print(error)
                        return Single.never()
                    }
            }
            .subscribe(with: self) { owner, cityList in
                print(cityList.prefix(10))
            }
            .disposed(by: disposeBag)
            
        
       return Output()
    }
    
}
