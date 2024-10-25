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
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

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
        titleLabel.font = .systemFont(ofSize: 14)
        averageLabel.textColor = .white
        averageLabel.numberOfLines = 2
        averageLabel.font = .systemFont(ofSize: 34, weight: .medium)
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.textColor = .white
    }
    
    func configureData(_ data: DetailWeather) {
        titleLabel.text = data.title
        averageLabel.text = data.average
        
        if data.title == Constant.DetailTitle.pressure.rawValue {
            averageLabel.asFont(target: "hpa", font: .systemFont(ofSize: 25))
        }
        
        if let description = data.description {
            descriptionLabel.text = description
        } else {
            descriptionLabel.text = ""
        }
    }
}
