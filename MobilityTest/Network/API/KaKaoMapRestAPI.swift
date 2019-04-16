//
//  KaKaoMapRestAPI.swift
//  Mobility
//
//  Created by gguby's macMini on 4/12/19.
//  Copyright © 2019 wsjung. All rights reserved.
//

import Foundation
import Moya

enum KaKaoMapRestAPI {
    
    private var APIKEY: String {
        get {
            return "cd777a9cb6994f1b4048127a3e1f9233"
        }
    }
    
    case category(_ category: CategoryGroup, _ point: MTMapPoint, _ radius: Int, _ page: Int)
}

extension KaKaoMapRestAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://dapi.kakao.com/")!
    }
    
    var path: String {
        switch self {
        case .category:
            return "/v2/local/search/category.json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case let .category(category, point, radius, page):
            let geo = point.mapPointGeo()
            return .requestParameters(parameters: ["category_group_code": category, "x" : geo.longitude, "y": geo.latitude, "radius": radius, "page": page], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": "KakaoAK " + APIKEY]
    }
}
