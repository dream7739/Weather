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
    private let emptyResultView = EmptyResultView()
    
    let searchResultUpdator = PublishRelay<String>()
    let didSelectCityUpdator = PublishRelay<Coord>()
    private let viewModel: CitySearchViewModel
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureCollectionView()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if UserManager.shared.getListCount() > 0 {
            cityCollectionView.scrollToItem(
                at: IndexPath(item: 0, section: 0),
                at: .top,
                animated: false
            )
            return
        }
        
        if !viewModel.cityList.isEmpty {
            cityCollectionView.scrollToItem(
                at: IndexPath(item: 0, section: 1),
                at: .top,
                animated: false
            )
        }
    }
    
    init(viewModel: CitySearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureHierarchy() {
        view.addSubview(cityCollectionView)
        view.addSubview(emptyResultView)
    }
    
    override func configureLayout() {
        cityCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        emptyResultView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
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
            searchResultUpdator: searchResultUpdator,
            saveRecentSearch: PublishRelay<CityResult>()
        )
        
        let output = viewModel.transform(input: input)
        let dataSource = configureDataSource()
        
        cityCollectionView.rx
            .modelSelected(SearchSectionItem.self)
            .bind(with: self) { owner, sectionItem in
                switch sectionItem {
                case .recent(let data):
                    owner.didSelectCityUpdator.accept(data.coord)
                case .city(let data):
                    input.saveRecentSearch.accept(data)
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
        
        output.sections
            .map { $0.count >= 2 && !$0[1].items.isEmpty }
            .bind(to: emptyResultView.rx.isHidden)
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
                cell.configureData(data.name)
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
            heightDimension: .estimated(30)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(340),
                                               heightDimension: .estimated(30))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 15,
            bottom: 0,
            trailing: 15
        )
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 6
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
