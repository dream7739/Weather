//
//  RecentSearchCell.swift
//  Weather
//
//  Created by 홍정민 on 10/25/24.
//

import UIKit
import SnapKit

final class RecentSearchCell: BaseCollectionViewCell {
    private let recentKeywordLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(recentKeywordLabel)
    }
    
    override func configureLayout() {
        recentKeywordLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    override func configureUI() {
        backgroundColor = .systemGray5
        layer.cornerRadius = 15
        clipsToBounds = true
        recentKeywordLabel.font = .systemFont(ofSize: 13)
    }
    
    func configureData(_ data: String){
        recentKeywordLabel.text = data
    }
}
