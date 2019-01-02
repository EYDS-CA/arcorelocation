//
//  ListLandmarksConfiguration.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit
import ARCoreLocation
import ARKit
import CoreLocation

extension ListLandmarks {
    static func scene() -> UINavigationController {
        let (viewController, navigationController) = ListLandmarksViewController.initFromStoryboardInNavigationController()
        let interactor = ListLandmarksInteractor()
        let presenter = ListLandmarksPresenter()
        let router = ListLandmarksRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.displayer = viewController
        router.viewController = viewController
        router.dataStore = interactor
        
        viewController.landmarker = ARLandmarker(view: ARSKView(),
                                                 scene: InteractiveScene(),
                                                 locationManager: CLLocationManager())
        return navigationController
    }
}
