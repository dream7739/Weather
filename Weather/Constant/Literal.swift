//
//  Literal.swift
//  Weather
//
//  Created by 홍정민 on 10/26/24.
//

import Foundation

enum Literal {
    enum Message {
        static let network = "오류가 발생하였습니다"
        static let json = "도시 정보를 가져올 수 없습니다"
    }
    
    enum Json {
        static let fileExtension = "json"
        static let fileName = "reduced_citylist"
    }
}
