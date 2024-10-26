//
//  WeatherBackgroundView.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit
import SnapKit

final class WeatherBackgroundView: BaseReusableView {
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    override func configureHierarchy() {
        addSubview(blurEffectView)
    }
    
    override func configureLayout() {
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureUI() {
        blurEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}
