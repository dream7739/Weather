//
//  WeatherViewController.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class WeatherViewController: BaseViewController {
    private let cityViewController = CitySearchViewController()
    private lazy var searchController = UISearchController(
        searchResultsController: cityViewController
    )
    private lazy var weatherCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    )
    private let viewModel = WeatherViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureSearchController()
        configureCollectionView()
    }
    
    override func configureHierarchy() {
        view.addSubview(weatherCollectionView)
    }
    
    override func configureLayout() {
        weatherCollectionView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        weatherCollectionView.backgroundColor = .red
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
        let dataSource = configureDataSource()
        
        output.sections
            .bind(to: weatherCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
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
    
    private func configureCollectionView() {
        weatherCollectionView.register(
            WeatherMainCell.self,
            forCellWithReuseIdentifier: WeatherMainCell.reuseIdentifier
        )
        weatherCollectionView.register(
            HourWeatherCell.self,
            forCellWithReuseIdentifier: HourWeatherCell.reuseIdentifier
        )
        weatherCollectionView.register(
            WeekWeatherCell.self,
            forCellWithReuseIdentifier: WeekWeatherCell.reuseIdentifier
        )
        weatherCollectionView.register(
            WeatherMapCell.self,
            forCellWithReuseIdentifier: WeatherMapCell.reuseIdentifier
        )
        weatherCollectionView.register(
            WeatherDetailCell.self,
            forCellWithReuseIdentifier: WeatherDetailCell.reuseIdentifier
        )
        
        weatherCollectionView.register(WeatherHeaderView.self,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                       withReuseIdentifier: WeatherHeaderView.reuseIdentifier)
    }
    
}

extension WeatherViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            switch section {
            case .main:
                return self?.createMainSection()
            case .hour:
                return self?.createHourlySection()
            case .week:
                return self?.createWeeklySection()
            case .map:
                return self?.createMapSection()
            case .detail:
                return self?.createDetailsSection()
            }
        }
        
        layout.register(
            WeatherBackgroundView.self,
            forDecorationViewOfKind: WeatherBackgroundView.reuseIdentifier
        )
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 15
        layout.configuration = configuration
        return layout
    }
    
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<WeatherSectionModel> {
        return RxCollectionViewSectionedReloadDataSource(configureCell:  { dataSource, collectionView, indexPath, _ in
            switch dataSource[indexPath] {
            case .main(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherMainCell.reuseIdentifier, for: indexPath) as? WeatherMainCell else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            case .hour(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourWeatherCell.reuseIdentifier, for: indexPath) as? HourWeatherCell else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            case .week(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekWeatherCell.reuseIdentifier, for: indexPath) as? WeekWeatherCell else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            case .map(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherMapCell.reuseIdentifier, for: indexPath) as? WeatherMapCell else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            case .detail(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherDetailCell.reuseIdentifier, for: indexPath) as? WeatherDetailCell else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            }
        }) { dataSource, collectionView, kind, indexPath in
            if let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: WeatherHeaderView.reuseIdentifier, for: indexPath) as? WeatherHeaderView {
                header.setTitle("강수량")
                return header
            }
            
            return UICollectionReusableView()
        }
    }
    
    private func createMainSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 44,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        return section
    }
    
    private func createHourlySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                              heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8),
                                               heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let header = createHeader()
        section.boundarySupplementaryItems = [header]
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: WeatherBackgroundView.reuseIdentifier)
        section.decorationItems = [backgroundItem]
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 10,
            trailing: 10
        )
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        return section
    }
    
    private func createWeeklySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 10,
            trailing: 10
        )
        let header = createHeader()
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: WeatherBackgroundView.reuseIdentifier)
        section.decorationItems = [backgroundItem]
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createMapSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 10,
            trailing: 10
        )
        let header = createHeader()
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: WeatherBackgroundView.reuseIdentifier)
        section.decorationItems = [backgroundItem]
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createDetailsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.5)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 10,
            trailing: 10
        )
        return section
    }
    
    private func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(30)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

extension WeatherViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
