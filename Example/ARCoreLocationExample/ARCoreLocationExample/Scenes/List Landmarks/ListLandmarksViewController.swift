//
//  ListLandmarksViewController.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit
import ARCoreLocation
import CoreLocation

protocol ListLandmarksRequestable {
    func fetchLandmarks(request: ListLandmarks.FetchLandmarks.Request)
}

protocol ListLandmarksRouteRequestable {
    func showLandmark(withIndex index: Int)
}

class ListLandmarksViewController: UIViewController {
    var interactor: ListLandmarksRequestable?
    var router: ListLandmarksRouteRequestable?
    
    var landmarker: ARLandmarker!
    /// Map from ARLandmark names to Indices
    var displayedLandmarks: [String: Int] = [:]
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure Landmarker
        landmarker.delegate = self
        landmarker.maximumVisibleDistance = 30_000_000 // Only show landmarks within 30,000km from user.
        
        // The landmarker can scale views so that closer ones appear larger than further ones. This scaling is linear
        // from 0 to `maxViewScaleDistance`.
        // For example, with `minViewScale` at `0.5` and `maxViewScaleDistance` at `1000`, a landmark 500 meters away
        // appears at a scale of `0.75`. A landmark 1000 meters or more away appears at a scale of `0.5`. A landmark
        // 0 meters away appears full scale (`1.0`).
        landmarker.minViewScale = 0.5 // Shrink distant landmark views to half size
        landmarker.maxViewScaleDistance = 5_000_000 // Show landmarks 5,000km or further at the smallest size
        
        landmarker.worldRecenteringThreshold = 30 // Recalculate the landmarks whenever the user moves 30 meters.
        landmarker.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // You'll usually want the best accuracy you can get.
        
        // Show all the landmarks, even when they are overlapping. Another common option is to show just the nearest
        // ones (`.showNearest`). If landmark views overlap, `.showNearest` will hide the landmarks that are further
        // away.
        landmarker.overlappingLandmarksStrategy = .showAll
        landmarker.beginEvaluatingOverlappingLandmarks(atInterval: 1.0) // Set how often to check for overlapping landmarks.
        
        view.addSubview(landmarker.view)
        
        // Using a VIP cycle here. The interactor will get the landmark data, and `displayLandmarks` will be called when the data is ready.
        interactor?.fetchLandmarks(request: ListLandmarks.FetchLandmarks.Request())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        landmarker.view.frame = view.bounds
        landmarker.scene.size = view.bounds.size
    }
}

extension ListLandmarksViewController: ListLandmarksDisplayer {
    func displayLandmarks(viewModel: ListLandmarks.FetchLandmarks.ViewModel) {
        for landmark in viewModel.landmarks {
            let markView = ListLandmarksItem.fromNib()
            markView.set(name: landmark.name, altitude: landmark.altitude)
            landmarker.addLandmark(view: markView, at: landmark.location) { [weak self] (arLandmark) in
                guard let mark = arLandmark else {
                    return
                }
                self?.displayedLandmarks[mark.name] = landmark.index
            }
        }
    }
}

extension ListLandmarksViewController: ARLandmarkerDelegate {
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didTap landmark: ARLandmark) {
        guard let index = displayedLandmarks[landmark.name] else {
            return
        }
        router?.showLandmark(withIndex: index)
    }
    
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didFailWithError error: Error) {
        print("Failed! Error: \(error)")
    }
}
