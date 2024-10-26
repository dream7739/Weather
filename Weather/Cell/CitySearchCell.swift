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
    private let seperatorView = SeperatorView()
    
    override func configureHierarchy() {
        contentView.addSubview(cityLabel)
        contentView.addSubview(countryLabel)
        contentView.addSubview(seperatorView)
    }
    
    override func configureLayout() {
        cityLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
        }
        
        countryLabel.snp.makeConstraints { make in
            make.top.equalTo(cityLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(cityLabel)
        }
        
        seperatorView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func configureUI() {
        cityLabel.font = Design.Font.secondaryBold
        cityLabel.textColor = .white
        countryLabel.font = Design.Font.tertiary
        countryLabel.textColor = .white
    }
    
    func configureData(_ data: CityResult) {
        cityLabel.text = data.name
        countryLabel.text = data.country
    }
}
