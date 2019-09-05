//
//  ListAssessmentsItem.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit

class ListLandmarksItem: UIView {
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var distanceLabel: UILabel!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var pinEnd: UIView!
    
    static func fromNib() -> ListLandmarksItem {
        let view = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)!.first as! ListLandmarksItem
        view.frame.size = CGSize(width: 340, height: 120)
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pinView.layer.cornerRadius = 12
        pinEnd.layer.cornerRadius = pinEnd.frame.width / 2
    }
    
    func set(name: String, detail: String?) {
        nameLabel.text = name
        distanceLabel.text = detail
        layoutIfNeeded()
    }
}
