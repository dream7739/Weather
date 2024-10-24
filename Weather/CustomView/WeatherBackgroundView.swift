//
//  WeatherBackgroundView.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit

final class WeatherBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white.withAlphaComponent(0.4)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
