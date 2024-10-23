//
//  BaseViewModel.swift
//  Weather
//
//  Created by 홍정민 on 10/23/24.
//

import Foundation
import RxSwift

protocol BaseViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
    var disposeBag: DisposeBag { get set }
    func transform()
}
