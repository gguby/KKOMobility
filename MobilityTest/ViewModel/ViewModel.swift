//
//  ViewModel.swift
//  MobilityTest
//
//  Created by gguby's macMini on 4/14/19.
//  Copyright © 2019 gguby's macMini. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel: NSObject {
    
    private let provider: NetworkProvider = NetworkProvider()
    
    // Delegate 전달용 클로저
    var didUpdateCircleLocation: ((MTMapPoint) -> ())?
    
    // State
    private var mapPointSubject = PublishSubject<(MTMapPoint, Int)>()
    private var movedMapSubject = PublishSubject<Bool>()
    private var selectItemSuject = PublishSubject<Void>()
    private var disposeBag = DisposeBag()

    private var currentCategory: CategoryGroup? = nil
    private var sections: [DocumentSection]!
    
    struct Input {
        let category: Observable<CategoryGroup>
        let nextPage: Observable<Void>
        let refresh: Observable<Void>
    }
    
    struct Output {
        let sectionModel: Observable<([DocumentSection], Bool)>
        let movedMap: Observable<Bool>
    }
    
    func transfrom(_ input: Input) -> Output {
        let next = input.nextPage.scan(1) { (page,_) -> Int in
            return page + 1
            }.map { $0 }
        
        let category = input.category.do(onNext: { [unowned self] (category) in
            self.currentCategory = category
        })
        
        let refresh = Observable.merge(input.refresh, selectItemSuject.asObservable()).do(onNext: { [unowned self]_ in
            self.movedMapSubject.onNext(false)
        })
        
        let setCommand = category.withLatestFrom(mapPointSubject) { [unowned self] (category, point) -> Observable<([DocumentSection],Bool)> in
            return self.provider.category(category, point.0, point.1, 1).map({ (response) -> ([DocumentSection],Bool) in
                self.movedMapSubject.onNext(false)
                var sections = [DocumentSection]()
                let section = DocumentSection(items: response.documents)
                sections.append(section)
                return (sections, false)
            })
            }.flatMap{ $0 }.map { Command.set(sections: $0) }
        
        let nextCommand = Observable.combineLatest(next,
                                                   mapPointSubject.asObservable())
            .withLatestFrom(input.category) { [unowned self] (arg0, category) -> Observable<([DocumentSection],Bool)> in
                let (next, point) = arg0
                return self.provider.category(category, point.0, point.1, next).map({ response -> ([DocumentSection],Bool) in
                    var sections = [DocumentSection]()
                    let section = DocumentSection(items: response.documents)
                    sections.append(section)
                    return (sections, response.meta.isEnd)
                })
            }.flatMap { $0 }.map { Command.nextPage(sections: $0)}
                                            
        let refreshCommnad = refresh.withLatestFrom(mapPointSubject).map { [unowned self] (point, radius) -> Observable<([DocumentSection],Bool)> in
            return self.provider.category(self.currentCategory ?? CategoryGroup.HP8, point, radius, 1).map({ response -> ([DocumentSection],Bool) in
                var sections = [DocumentSection]()
                let section = DocumentSection(items: response.documents)
                sections.append(section)
                return (sections, response.meta.isEnd)
            })
            }.flatMap { $0 }.map { Command.set(sections: $0) }
        
        let sectionModel = Observable.merge(setCommand, nextCommand, refreshCommnad)
            .scan(([DocumentSection](), false)) { self.excute(command: $1) }
        
        return Output(sectionModel: sectionModel,
                      movedMap: self.movedMapSubject.asObservable() )
    }
    
    func excute(command: Command) -> ([DocumentSection],Bool) {
        switch command {
        case .set(let sections):
            self.sections = sections.0
            return (sections.0,sections.1)
        case .nextPage(let sections):
            if let oldSection = self.sections.last, let section = sections.0.last {
                var items = oldSection.items
                for document in section.items {
                    items.append(document)
                }
                
                let newSection = DocumentSection(items: items)
                return ([newSection], sections.1)
            }
            
            return (self.sections, false)
        }
    }
}

extension ViewModel: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, zoomLevelChangedTo zoomLevel: MTMapZoomLevel) {
        self.mapPointSubject.onNext((mapView.mapCenterPoint, Int(mapView.zoomLevel * 1000)))
    }
    
    func mapView(_ mapView: MTMapView!, centerPointMovedTo mapCenterPoint: MTMapPoint!) {
        self.mapPointSubject.onNext((mapView.mapCenterPoint, Int(mapView.zoomLevel * 1000)))
        self.movedMapSubject.onNext(true)
    }
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        didUpdateCircleLocation?(location)
        mapView.setZoomLevel(3, animated: true)
        self.mapPointSubject.onNext((location, Int(mapView.zoomLevel * 1000)))
    }
    
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        mapView.setMapCenter(poiItem.mapPoint, animated: true)
        self.mapPointSubject.onNext((poiItem.mapPoint, Int(mapView.zoomLevel * 1000)))
        self.selectItemSuject.onNext(())
        return true
    }
}

enum Command {
    case set(sections: ([DocumentSection], Bool))
    case nextPage(sections: ([DocumentSection], Bool))
}
