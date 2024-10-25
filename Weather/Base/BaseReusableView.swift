//
//  BaseReusableView.swift
//  Weather
//
//  Created by 홍정민 on 10/26/24.
//

import UIKit

class BaseReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() { }
    func configureLayout() { }
    func configureUI() { }
}
