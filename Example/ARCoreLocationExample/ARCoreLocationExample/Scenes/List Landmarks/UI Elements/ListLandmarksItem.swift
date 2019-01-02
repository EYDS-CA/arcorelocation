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
    @IBOutlet weak private var altitudeLabel: UILabel!
    
    static func fromNib() -> ListLandmarksItem {
        let view = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)!.first as! ListLandmarksItem
        view.frame.size = CGSize(width: 340, height: 80)
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        backgroundColor = UIColor.white.withAlphaComponent(0.85)
    }
    
    func set(name: String, altitude: String) {
        nameLabel.text = name
        altitudeLabel.text = altitude
        layoutIfNeeded()
    }
}
