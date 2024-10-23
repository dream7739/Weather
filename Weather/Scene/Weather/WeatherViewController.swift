//
//  WeatherViewController.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WeatherViewController: BaseViewController {
    private let cityViewController = CitySearchViewController()
    private lazy var searchController = UISearchController(searchResultsController: cityViewController)
    private let viewModel = WeatherViewModel()
    private let disposeBag = DisposeBag()
    
    enum Section: Int, CaseIterable {
         case main
         case hourly
         case weekly
         case map
         case details
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureSearchController()
    }
    
    func bind() {
        let input = WeatherViewModel.Input(
            callWeatherRequest: BehaviorRelay(
                value: Coord(
                    lat: 36.783611,
                    lon: 127.004173
                )
            )
        )
        
        let output = viewModel.transform(input: input)
    }
    
}

extension WeatherViewController {
    private func configureSearchController() {
         searchController.searchBar.placeholder = "Search"
         navigationItem.searchController = searchController
         searchController.searchBar.searchBarStyle = .minimal
         searchController.searchBar.backgroundColor = .clear
         searchController.searchBar.searchTextField.backgroundColor = .systemGray6.withAlphaComponent(0.6)
         searchController.searchResultsUpdater = self
     }
}

extension WeatherViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
