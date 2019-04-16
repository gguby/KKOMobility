//
//  NetworkProvider.swift
//  Mobility
//
//  Created by gguby's macMini on 4/12/19.
//  Copyright © 2019 wsjung. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class NetworkProvider {
    private let provider = MoyaProvider<KaKaoMapRestAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    func category(_ category: CategoryGroup,_ point: MTMapPoint, _ radius: Int ,_ page: Int) -> Observable<CategoryResponse> {
        return provider.rx
            .request(KaKaoMapRestAPI.category(category, point, radius, page))
            .asObservable()
            .map(CategoryResponse.self)
    }
}

