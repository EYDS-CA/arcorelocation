//
//  ListLandmarksPresenter.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit

protocol ListLandmarksDisplayer: class {
    func displayLandmarks(viewModel: ListLandmarks.FetchLandmarks.ViewModel)
}

class ListLandmarksPresenter {
    weak var displayer: ListLandmarksDisplayer?
}

extension ListLandmarksPresenter: ListLandmarksPresentationPreparer {
    func presentLandmarks(response: ListLandmarks.FetchLandmarks.Response) {
        typealias Landmark = ListLandmarks.FetchLandmarks.ViewModel.Landmark
        let landmarks = response.landmarks.map({ Landmark(name: $0.name, location: $0.location, details: $0.details, index: $0.index) })
        displayer?.displayLandmarks(viewModel: ListLandmarks.FetchLandmarks.ViewModel(landmarks: landmarks))
    }
}
