//
//  CitySearchViewController.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class CitySearchViewController: BaseViewController {
    private lazy var cityCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    )
    
    let searchResultUpdator = PublishRelay<String>()
    let didSelectCityUpdator = PublishRelay<Coord>()
    private let viewModel = CitySearchViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureCollectionView()
    }
    
    override func configureHierarchy() {
        view.addSubview(cityCollectionView)
    }
    
    override func configureLayout() {
        cityCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    override func configureUI() {
        cityCollectionView.keyboardDismissMode = .onDrag
        cityCollectionView.backgroundColor = .theme
        cityCollectionView.showsVerticalScrollIndicator = false
        view.backgroundColor = .theme
    }
    
    private func bind() {
        let input = CitySearchViewModel.Input(
            jsonParseRequest: BehaviorRelay(
                value: Literal.Json.fileName
            ),
            searchResultUpdator: searchResultUpdator
        )
        
        let output = viewModel.transform(input: input)
        let dataSource = configureDataSource()
        
        cityCollectionView.rx
            .modelSelected(SearchSectionItem.self)
            .bind(with: self) { owner, sectionItem in
                switch sectionItem {
                case .recent(let data):
                    print(data)
                case .city(let data):
                    owner.didSelectCityUpdator.accept(data.coord)
                }
            }
            .disposed(by: disposeBag)
        
        output.presentError
            .bind(with: self) { owner, message in
                owner.view.makeToast(message)
            }
            .disposed(by: disposeBag)
        
        output.sections
            .bind(to: cityCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension CitySearchViewController {
    private func configureCollectionView() {
        cityCollectionView.register(
            RecentSearchCell.self,
            forCellWithReuseIdentifier: RecentSearchCell.reuseIdentifier
        )
        cityCollectionView.register(
            CitySearchCell.self,
            forCellWithReuseIdentifier: CitySearchCell.reuseIdentifier
        )
    }
}

extension CitySearchViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = SearchSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .recent:
                return self?.createRecentSection()
            case .city:
                return self?.createCitySection()
                
            }
        }
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 15
        layout.configuration = configuration
        return layout
    }
    
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<SearchSectionModel> {
        return RxCollectionViewSectionedReloadDataSource(configureCell:  { dataSource, collectionView, indexPath, _ in
            switch dataSource[indexPath] {
            case .recent(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchCell.reuseIdentifier, for: indexPath) as? RecentSearchCell else { return UICollectionViewCell() }
                cell.configureData("")
                return cell
            case .city(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CitySearchCell.reuseIdentifier, for: indexPath) as? CitySearchCell else { return UICollectionViewCell() }
                cell.configureData(data)
                return cell
            }
        })
    }
    
    private func createRecentSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(50),
            heightDimension: .absolute(30)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(340),
                                               heightDimension: .absolute(30))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 15,
            bottom: 0,
            trailing: 15
        )
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 4
        return section
    }
    
    private func createCitySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 15,
            bottom: 0,
            trailing: 15
        )
        
        return section
    }
}
