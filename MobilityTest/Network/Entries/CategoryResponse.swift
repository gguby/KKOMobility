//
//  AddressrResponse.swift
//  Mobility
//
//  Created by gguby's macMini on 4/12/19.
//  Copyright © 2019 wsjung. All rights reserved.
//

import Foundation
import RxSwift
import Moya

protocol KKOResponse: Codable {
    var meta: Meta { get set }
    var documents: [Document] { get set }
}

extension KKOResponse {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        } else {
            // Fallback on earlier versions
        }
        return decoder
    }
}

struct CategoryResponse: Codable {
    let meta: Meta
    let documents: [Document]
}

struct Document: Codable {
    let placeName, distance: String
    let placeURL: String
    let categoryName, addressName, roadAddressName, id: String
    let phone, categoryGroupCode, categoryGroupName, x: String
    let y: String
    
    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case distance
        case placeURL = "place_url"
        case categoryName = "category_name"
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
        case id, phone
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case x, y
    }
}

struct Meta: Codable {
    let sameName: SameName?
    let pageableCount, totalCount: Int
    let isEnd: Bool
    
    enum CodingKeys: String, CodingKey {
        case sameName = "same_name"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
        case isEnd = "is_end"
    }
}

enum CategoryGroup: String {
    case HP8,PM9,OL7
}

struct SameName: Codable {
    let region: [String]
    let keyword: String
    let selected_region: String
}

extension ObservableType where E == Moya.Response {
    func map<T: KKOResponse>(_ type: T.Type) -> Observable<T> {
        return self.map(T.self, using: T.decoder).map({ (response) -> T in            
            return response
        }).do(onError: { error in
            if case let MoyaError.objectMapping(decodingError, _) = error {
                print(decodingError)
            }
        })
    }
}
