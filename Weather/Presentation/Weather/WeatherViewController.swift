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
import Toast

final class WeatherViewController: BaseViewController {
    private let cityViewController = CitySearchViewController(
        viewModel: CitySearchViewModel()
    )
    private lazy var searchController = UISearchController(
        searchResultsController: cityViewController
    )
    private lazy var weatherCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    )
    private let backgroundImageView = UIImageView()
    
    private let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureSearchController()
        configureCollectionView()
    }
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        navigationItem.hidesSearchBarWhenScrolling = false
        backgroundImageView.backgroundColor = .theme
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = weatherCollectionView.bounds
        weatherCollectionView.backgroundView = backgroundImageView
        weatherCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func bind() {
        let input = WeatherViewModel.Input(
            callWeatherRequest: BehaviorRelay(
                value: Coord(
                    lat: Literal.InitialCoord.lat,
                    lon: Literal.InitialCoord.lon
                )
            )
        )
        let output = viewModel.transform(input: input)
        let dataSource = configureDataSource()
        
        searchController.rx.present
            .bind(with: self) { owner, _ in
                guard let resultController = owner.searchController.searchResultsController as? CitySearchViewController 
                else { return }
                resultController.searchResultUpdator.accept("")
                owner.searchController.showsSearchResultsController = true
            }
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.text
            .orEmpty
            .bind(with: self) { owner, searchText in
                guard let resultController = owner.searchController.searchResultsController as? CitySearchViewController 
                else { return }
                resultController.searchResultUpdator.accept(searchText)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(searchController.rx.didDismiss, cityViewController.didSelectCityUpdator)
            .bind(with: self) { owner, _ in
                if !output.sections.value.isEmpty {
                    owner.weatherCollectionView.scrollToItem(
                        at: IndexPath(item: 0, section: 0),
                        at: .top,
                        animated: false
                    )
                }
            }
            .disposed(by: disposeBag)
        
        cityViewController.didSelectCityUpdator
            .bind(with: self) { owner, coord in
                owner.searchController.isActive = false
                input.callWeatherRequest.accept(coord)
            }
            .disposed(by: disposeBag)
        
        output.presentError
            .bind(with: self) { owner, message in
                if !message.isEmpty {
                    owner.view.makeToast(message)
                }
            }
            .disposed(by: disposeBag)
        
        output.setBackgroundImage
            .map { Constant.WeatherBackgroundImage(conditionCode: $0) }
            .map { UIImage(named: $0.rawValue) }
            .bind(to: backgroundImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.sections
            .bind(to: weatherCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}

extension WeatherViewController {
    private func configureSearchController() {
        searchController.searchBar.placeholder = Literal.Placeholder.search
        navigationItem.searchController = searchController
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = .systemGray6.withAlphaComponent(0.6)
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
        
        weatherCollectionView.register(
            WeatherHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: WeatherHeaderView.reuseIdentifier)
    }
    
}

extension WeatherViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = WeatherSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .main:
                return self?.createMainSection()
            case .hour:
                return self?.createHourSection()
            case .week:
                return self?.createWeekSection()
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
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherMainCell.reuseIdentifier, for: indexPath) as? WeatherMainCell 
                else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            case .hour(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourWeatherCell.reuseIdentifier, for: indexPath) as? HourWeatherCell 
                else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            case .week(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekWeatherCell.reuseIdentifier, for: indexPath) as? WeekWeatherCell 
                else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            case .map(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherMapCell.reuseIdentifier, for: indexPath) as? WeatherMapCell 
                else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            case .detail(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherDetailCell.reuseIdentifier, for: indexPath) as? WeatherDetailCell 
                else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            }
        }) { dataSource, collectionView, kind, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: WeatherHeaderView.reuseIdentifier, for: indexPath) as? WeatherHeaderView 
            else { return UICollectionReusableView() }
            
            switch dataSource[indexPath.section] {
            case .main, .detail: break
            case .hour(let header, _):
                headerView.setTitle(header)
            case .week(let header, _), .map(let header, _):
                headerView.setTitle(header)
                headerView.hideSeperator()
            }
        
            return headerView
        }
    }
    
    private func createMainSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 30,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        return section
    }
    
    private func createHourSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.15),
            heightDimension: .absolute(104)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(104)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 4,
            leading: 20,
            bottom: 0,
            trailing: 0
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        
        let header = createHeader()
        header.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 30,
            bottom: 0,
            trailing: 40
        )
        section.boundarySupplementaryItems = [header]
        
        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: WeatherBackgroundView.reuseIdentifier
        )
        backgroundItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 15,
            bottom: 0,
            trailing: 15
        )
        section.decorationItems = [backgroundItem]
        
        return section
    }
    
    private func createWeekSection() -> NSCollectionLayoutSection {
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
            leading: 30,
            bottom: 0,
            trailing: 30
        )
        
        let header = createHeader()
        section.boundarySupplementaryItems = [header]
        
        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: WeatherBackgroundView.reuseIdentifier
        )
        backgroundItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 15,
            bottom: 0,
            trailing: 15
        )
        section.decorationItems = [backgroundItem]
        
        return section
    }
    
    private func createMapSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemSize,subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 30,
            bottom: 15,
            trailing: 30
        )
        
        let header = createHeader()
        section.boundarySupplementaryItems = [header]
        
        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: WeatherBackgroundView.reuseIdentifier
        )
        backgroundItem.contentInsets =  NSDirectionalEdgeInsets(
            top: 0,
            leading: 15,
            bottom: 0,
            trailing: 15
        )
        section.decorationItems = [backgroundItem]
        
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
            heightDimension: .fractionalWidth(0.5)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 15,
            bottom: 15,
            trailing: 15
        )
        
        return section
    }
    
    private func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(40)
        )
        
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
