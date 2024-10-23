//
//  WeatherViewController.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import UIKit
import RxSwift
import RxCocoa

final class WeatherViewController: BaseViewController {

    private let viewModel = WeatherViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    func bind() {
        var input = WeatherViewModel.Input(
            callWeatherRequest: BehaviorRelay(
                value: Coord(
                    lat: 36.783611,
                    lon: 127.004173
                )
            )
        )
        
        var output = viewModel.transform(input: input)
    }

}

