//
//  WeatherHeaderView.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit
import SnapKit

final class WeatherHeaderView: BaseReusableView {
    private let titleLabel = UILabel()
    
    override func configureHierarchy() {
        addSubview(titleLabel)
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview()
        }
    }
    
    override func configureUI() {
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .white
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
