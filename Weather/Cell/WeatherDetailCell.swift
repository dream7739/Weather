//
//  WeatherDetailCell.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit
import SnapKit

final class WeatherDetailCell: BaseCollectionViewCell {
    private let titleLabel = UILabel()
    private let averageLabel = UILabel()
    private let descriptionLabel = UILabel()

    override func configureHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(averageLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
      
        averageLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.centerY.equalTo(contentView)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(contentView.snp.bottom).inset(8)
        }
    }
    
    override func configureUI() {    
        backgroundColor = .white.withAlphaComponent(0.4)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 12)
        averageLabel.textColor = .white
        averageLabel.numberOfLines = 2
        averageLabel.font = .systemFont(ofSize: 32, weight: .medium)
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.textColor = .white
    }
    
    func configureData(_ data: DetailWeather) {
        titleLabel.text = data.title
        averageLabel.text = data.average
        if let description = data.description {
            descriptionLabel.text = description
        } else {
            descriptionLabel.text = ""
        }
    }
}
