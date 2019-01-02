//
//  ListAssessmentsItem.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit

class ListLandmarksItem: UIView {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    static func fromNib() -> ListLandmarksItem {
        let view = Bundle.main.loadNibNamed("ListAssessmentsItem", owner: nil, options: nil)!.first as! ListLandmarksItem
        view.frame.size = CGSize(width: 340, height: 100)
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        backgroundColor = UIColor.white.withAlphaComponent(0.85)
    }
    
    func set(address: String, amount: String) {
        addressLabel.text = address
        amountLabel.text = amount
        layoutIfNeeded()
    }
}
