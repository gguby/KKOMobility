//
//  AddressTableViewCell.swift
//  MobilityTest
//
//  Created by gguby's macMini on 4/14/19.
//  Copyright © 2019 gguby's macMini. All rights reserved.
//

import Foundation

class KKOLocationCell: UITableViewCell {
    
    static let cellId = "KKOCell"
    
    private lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var lblDesc: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        label.textColor = UIColor(white: 152.0 / 255.0, alpha: 1.0)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(lblTitle)
        contentView.addSubview(lblDesc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cellRect = self.contentView.bounds
        lblTitle.frame = CGRect(x: 20, y: 15, width: cellRect.width-20, height: 15)
        lblDesc.frame = CGRect(x: 20, y: 35, width: cellRect.width-20, height: 12)
    }
    
    func configure(document: Document) {
        lblTitle.text = document.placeName
        lblDesc.text = document.roadAddressName
    }
}
