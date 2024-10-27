//
//  EmptyResultView.swift
//  Weather
//
//  Created by 홍정민 on 10/27/24.
//

import UIKit
import SnapKit

final class EmptyResultView: BaseView {
    private let descriptionLabel = UILabel()
    
    override func configureHierarchy() {
        addSubview(descriptionLabel)
    }
    
    override func configureLayout() {
        descriptionLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func configureUI() {
        backgroundColor = .clear
        descriptionLabel.font = Design.Font.primary
        descriptionLabel.textColor = .white
        descriptionLabel.text = Literal.Message.emptyResult
    }
}
