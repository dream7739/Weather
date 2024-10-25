//
//  SeperatorView.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import UIKit
import SnapKit

final class SeperatorView: BaseView {    
    override func configureHierarchy() {
        snp.makeConstraints { make in
            make.height.equalTo(0.7)
        }
    }
    
    override func configureUI() {
        backgroundColor = .systemGray5
    }
}
