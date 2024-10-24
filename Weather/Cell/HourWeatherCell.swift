//
//  HourWeatherCell.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit
import SnapKit

final class HourWeatherCell: BaseCollectionViewCell {
    private let timeLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let weatherImageView = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(weatherImageView)
    }
    
    override func configureLayout() {
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.centerX.equalTo(contentView)
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.centerX.equalTo(contentView)
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherImageView.snp.bottom).offset(8)
            make.centerX.equalTo(contentView)
        }
    }
    
    override func configureUI() {
        timeLabel.font = .systemFont(ofSize: 15)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        
        weatherImageView.contentMode = .scaleAspectFit
        weatherImageView.tintColor = .white
        temperatureLabel.font = .systemFont(ofSize: 20)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
    }
    
    func configureData(_ data: HourWeather) {
        timeLabel.text = data.hour
        weatherImageView.image = UIImage(named: data.weather)
        temperatureLabel.text = data.temp
    }
}
