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
    private let seperatorView = SeperatorView()
    
    override func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(seperatorView)
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        
        seperatorView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    override func configureUI() {
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func hideSeperator() {
        seperatorView.isHidden = true
    }
}
