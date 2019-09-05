//
//  ListLandmarksRouter.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit

protocol ListLandmarksDataStorer {
    func place(forIndex index: Int) -> VictoriaLandmark?
}

class ListLandmarksRouter {
    weak var viewController: ListLandmarksViewController?
    var dataStore: ListLandmarksDataStorer?
}

extension ListLandmarksRouter: ListLandmarksRouteRequestable {
    func showLandmark(withIndex index: Int) {
        guard let place = dataStore?.place(forIndex: index), let details = place.details else {
            return
        }
        let alert = UIAlertController(title: place.name, message: details, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        viewController?.present(alert, animated: true, completion: nil)
    }
}
