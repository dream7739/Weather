//
//  CitySearchViewController.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CitySearchViewController: BaseViewController {
    private let viewModel = CitySearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        print(#function)
        let input = CitySearchViewModel.Input(
            jsonParseRequest: BehaviorRelay(
                value: Constant.jsonFileName
            )
        )
        
        let output = viewModel.transform(input: input)
    }
}
