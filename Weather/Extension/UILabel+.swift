//
//  UILabel+.swift
//  Weather
//
//  Created by 홍정민 on 10/26/24.
//

import UIKit

extension UILabel {
    func asFont(target: String, font: UIFont) {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: target)
        attributedString.addAttribute(.font, value: font, range: range)
        attributedText = attributedString
    }
}
