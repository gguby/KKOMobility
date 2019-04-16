//
//  ViewController.swift
//  MobilityTest
//
//  Created by gguby's macMini on 4/12/19.
//  Copyright © 2019 gguby's macMini. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import ReusableKit
import SnapKit

class ViewController: UIViewController {
    
    private struct Reusable
    {
        static let cell = ReusableCell<AddressTableViewCell>()
    }
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var btnMore: UIButton!
    
    private var mapView: MTMapView!
    private var currentCircle: MTMapCircle?
    private let viewModel = ViewModel()
    
    private var currentPage = 1
    private var oldCategory: String!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<DocumentSection>!
    private var disposeBag = DisposeBag()
    
    
    private lazy var btnRefresh: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "refresh"), for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    private lazy var btnHospital: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "hospi"), for: .normal)
        btn.tag = 0
        return btn
    }()
    
    private lazy var btnPM: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "pham"), for: .normal)
        btn.tag = 1
        return btn
    }()
    
    private lazy var btnOil: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "gas"), for: .normal)
        btn.tag = 2
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initMapView()
        initSubView()
        initTableView()
        viewModelBind()
    }
    
    private func initMapView() {
        mapView = MTMapView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: containerView.frame.width,
                                          height: containerView.frame.height))
        
        mapView.delegate = viewModel
        mapView.baseMapType = .standard
        mapView.currentLocationTrackingMode = .onWithoutHeading
//        mapView.showCurrentLocationMarker = true
        containerView.addSubview(mapView)
    }
    
    private func initCurrentCircle(point: MTMapPoint) {
        if let _ = self.currentCircle {
            mapView.removeCircle(self.currentCircle)
        }
        
        currentCircle = MTMapCircle()
        currentCircle?.circleLineColor = .white
        currentCircle?.circleFillColor = .red
        currentCircle?.circleRadius = Float(self.mapView.zoomLevel * 15)
        currentCircle?.circleCenterPoint = point

        mapView.addCircle(currentCircle)
        mapView.fitArea(toShow: currentCircle)
    }
    
    private func initSubView(){
        containerView.addSubview(btnRefresh)
        containerView.addSubview(btnHospital)
        containerView.addSubview(btnPM)
        containerView.addSubview(btnOil)
        
        btnRefresh.snp.makeConstraints { make in
            make.centerX.equalTo(containerView.snp.centerX)
            make.top.equalTo(20)
        }
        
        btnHospital.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(32)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
            make.right.equalTo(btnPM.snp.left).offset(-5)
        }
        
        btnPM.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(32)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
            make.right.equalTo(btnOil.snp.left).offset(-5)
        }
        
        btnOil.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(32)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
            make.right.equalTo(containerView.snp.right).offset(-20)
        }
    }
    
    private func initTableView() {
        tableView.tableFooterView = footerView
        tableView.register(Reusable.cell)
        tableView.rowHeight = 50
        
        dataSource = RxTableViewSectionedReloadDataSource<DocumentSection> (configureCell: { (_, tableView, indexPath, item)  in
            let cell = tableView.dequeue(Reusable.cell, for: indexPath)
            cell.configure(document: item)
            return cell
        })
    }
    
    private func viewModelBind() {
    
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] index in
                guard let `self` = self else { return }
                self.tableView.deselectRow(at: index, animated: true)
            }).disposed(by: disposeBag)
        
        btnRefresh.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.mapView.removeAllPOIItems()
            self.btnRefresh.isHidden = true
            self.btnMore.isHidden = true
        }).disposed(by: disposeBag)
        
        // Marker 이벤트
        let categoyGroup = Observable.merge(btnHospital.rx.tap.map { CategoryGroup.HP8 },
                                            btnPM.rx.tap.map { CategoryGroup.PM9 },
                                            btnOil.rx.tap.map { CategoryGroup.OL7 })
        
        let output = viewModel.transfrom(ViewModel.Input(category: categoyGroup,
                                                         nextPage: self.btnMore.rx.tap.map {()},
                                                         refresh: self.btnRefresh.rx.tap.map{()}))
        
        output.sectionModel
            .do(onNext: { [weak self] model in
                guard let self = self else { return }
                guard let section = model.0.first else { return }
                self.btnMore.isHidden = model.1
                self.btnRefresh.isHidden = false
                var items = [MTMapPOIItem]()
                for document in section.items {
                    let poiItem = self.poiItem(name: document.placeName, latitude: document.y.toDouble()!, longitude: document.x.toDouble()!, category: CategoryGroup(rawValue: document.categoryGroupCode))
                    items.append(poiItem)
                }
                
                self.mapView.addPOIItems(items)
            })
            .map { $0.0 }
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
    }
}

extension ViewController {
    private func poiItem(name: String, latitude: Double, longitude: Double, category: CategoryGroup?) -> MTMapPOIItem {
        let item = MTMapPOIItem()
        item.itemName = name
        if let category = category {
            switch category {
            case .HP8:
                item.markerType = .redPin
            case .OL7:
                item.markerType = .bluePin
            case .PM9:
                item.markerType = .yellowPin
            }
        }else {
            item.markerType = .redPin
        }
        
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        item.customImageAnchorPointOffset = .init(offsetX: 30, offsetY: 0)
        
        return item
    }
}
