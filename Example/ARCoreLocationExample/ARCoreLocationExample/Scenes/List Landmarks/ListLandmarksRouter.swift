//
//  ListLandmarksRouter.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit

protocol ListLandmarksDataStorer {
    func mountain(forIndex index: Int) -> Mountain?
}

class ListLandmarksRouter {
    weak var viewController: ListLandmarksViewController?
    var dataStore: ListLandmarksDataStorer?
}

extension ListLandmarksRouter: ListLandmarksRouteRequestable {
    func showLandmark(withIndex index: Int) {
        guard let mountain = dataStore?.mountain(forIndex: index) else {
            return
        }
        let alert  = UIAlertController(title: nil, message: "That's \(mountain.name)", preferredStyle: .alert)
        viewController?.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
