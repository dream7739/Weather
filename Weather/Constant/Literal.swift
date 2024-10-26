//
//  Literal.swift
//  Weather
//
//  Created by 홍정민 on 10/26/24.
//

import Foundation

enum Literal {
    enum Placeholder {
        static let search = "Search"
    }
    
    enum Message {
        static let network = "오류가 발생하였습니다"
        static let json = "도시 정보를 가져올 수 없습니다"
    }
    
    enum Json {
        static let fileExtension = "json"
        static let fileName = "reduced_citylist"
    }
    
    enum InitialCoord {
        static let lat = 36.783611
        static let lon = 127.004173
    }
    
}
