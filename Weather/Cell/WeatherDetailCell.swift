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
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

    override func configureHierarchy() {
        contentView.addSubview(blurEffectView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(averageLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    override func configureLayout() {
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView.safeAreaLayoutGuide).inset(15)
        }
      
        averageLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.centerY.equalTo(contentView)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(contentView.snp.bottom).inset(15)
        }
    }
    
    override func configureUI() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        titleLabel.textColor = .white
        titleLabel.font = Design.Font.secondary
        averageLabel.textColor = .white
        averageLabel.numberOfLines = 2
        averageLabel.font = Design.Font.title
        descriptionLabel.font = Design.Font.tertiary
        descriptionLabel.textColor = .white
    }
    
    func configureData(_ data: DetailWeather) {
        titleLabel.text = data.title
        averageLabel.text = data.average
        
        if data.title == Literal.WeatherTitle.pressure.rawValue {
            averageLabel.asFont(
                target: Literal.Weather.hpa,
                font: .systemFont(ofSize: 25)
            )
        }
        
        if let description = data.description {
            descriptionLabel.text = description
        } else {
            descriptionLabel.text = ""
        }
    }
}
