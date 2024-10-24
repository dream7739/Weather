//
//  WeatherHeaderView.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit
import SnapKit

final class WeatherHeaderView: UICollectionReusableView {
    private let titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configureHierarchy() {
        addSubview(titleLabel)
    }
    
    private func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        }
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
