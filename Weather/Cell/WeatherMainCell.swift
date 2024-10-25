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
            make.top.equalTo(contentView).offset(8)
            make.centerX.equalTo(contentView)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(cityLabel.snp.bottom).offset(8)
            make.centerX.equalTo(contentView)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(8)
            make.centerX.equalTo(contentView)
        }
        
        highLowLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.centerX.equalTo(contentView)
        }
    }
    
    override func configureUI() {
        cityLabel.font = .systemFont(ofSize: 34, weight: .medium)
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center
        
        temperatureLabel.font = .systemFont(ofSize: 60, weight: .thin)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        
        descriptionLabel.font = .systemFont(ofSize: 24)
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
        highLowLabel.text = "최고: \(data.highTemp) | 최저: \(data.lowTemp)"
    }
}
