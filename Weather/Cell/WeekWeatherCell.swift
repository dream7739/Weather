//
//  WeekWeatherCell.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit
import SnapKit

final class WeekWeatherCell: BaseCollectionViewCell {
    private let weekDayLabel = UILabel()
    private let weatherImageView = UIImageView()
    private let lowTempLabel = UILabel()
    private let highTempLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(weekDayLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(lowTempLabel)
        contentView.addSubview(highTempLabel)
    }
    
    override func configureLayout() {
        weekDayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(8)
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.centerX.equalTo(contentView.safeAreaLayoutGuide).multipliedBy(0.6)
            make.size.equalTo(30)
        }
        
        lowTempLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(highTempLabel.snp.leading).offset(-8)
        }
        
        highTempLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).offset(-8)
        }
        
    }
    
    override func configureUI() {
        weekDayLabel.textColor = .white
        weekDayLabel.font = .systemFont(ofSize: 18)
        lowTempLabel.textColor = .white
        lowTempLabel.font = .systemFont(ofSize: 18)
        highTempLabel.textColor = .white
        highTempLabel.font = .systemFont(ofSize: 18)
    }
    
    func configureData(_ data: WeekWeather){
        weekDayLabel.text = data.weekDay
        weatherImageView.image = UIImage(named: data.weather)
        lowTempLabel.text = data.lowTemp
        highTempLabel.text = data.highTemp
    }
}
