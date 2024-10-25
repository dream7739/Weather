//
//  CitySearchCell.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import UIKit
import SnapKit

final class CitySearchCell: BaseCollectionViewCell {
    private let cityLabel = UILabel()
    private let countryLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(cityLabel)
        contentView.addSubview(countryLabel)
    }
    
    override func configureLayout() {
        cityLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
        }
        
        countryLabel.snp.makeConstraints { make in
            make.top.equalTo(cityLabel.snp.bottom).offset(4)
            make.leading.equalTo(cityLabel)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        cityLabel.font = .boldSystemFont(ofSize: 13)
        cityLabel.textColor = .white
        countryLabel.font = .systemFont(ofSize: 11)
        countryLabel.textColor = .white
    }
    
    func configureData(_ data: CityResult) {
        cityLabel.text = data.name
        countryLabel.text = data.country
    }
}
