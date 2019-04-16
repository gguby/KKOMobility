//
//  AdreesSection.swift
//  MobilityTest
//
//  Created by gguby's macMini on 4/14/19.
//  Copyright © 2019 gguby's macMini. All rights reserved.
//

import Foundation
import RxDataSources

struct DocumentSection {
    var items: [Item]
}

extension DocumentSection: SectionModelType {
    typealias Item = Document
    
    init(original: DocumentSection, items: [Document]) {
        self = original
        self.items = items
    }
}


extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
