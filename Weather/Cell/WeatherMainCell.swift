//
//  WeatherMainCell.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit
import SnapKit

final class WeatherMainCell: BaseCollectionViewCell {
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let highLowLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(cityLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(highLowLabel)
    }
    
    override func configureLayout() {
        cityLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(8)
            make.centerX.equalTo(contentView.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(15)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(cityLabel.snp.bottom).offset(8)
            make.centerX.equalTo(contentView.safeAreaLayoutGuide)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(8)
            make.centerX.equalTo(contentView.safeAreaLayoutGuide)
        }
        
        highLowLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.centerX.equalTo(contentView.safeAreaLayoutGuide)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
        }
    }
    
    override func configureUI() {
        cityLabel.font = Design.Font.title
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center
        cityLabel.numberOfLines = 2
        temperatureLabel.font = .systemFont(ofSize: 80)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        descriptionLabel.font = Design.Font.title
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        highLowLabel.font = .systemFont(ofSize: 20)
        highLowLabel.textColor = .white
        highLowLabel.textAlignment = .center
    }
    
    func configureData(_ data: MainWeather) {
        cityLabel.text = data.city
        temperatureLabel.text = data.temperature
        descriptionLabel.text = data.description
        highLowLabel.text = data.tempDescription
    }
}
