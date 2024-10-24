//
//  ReusableProtocol.swift
//  Weather
//
//  Created by 홍정민 on 10/24/24.
//

import UIKit

protocol ReusableProtocol {
    static var reuseIdentifier: String { get }
}

extension UIView: ReusableProtocol {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
