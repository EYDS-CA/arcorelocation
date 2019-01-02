//
//  ListLandmarksInteractor.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate typealias Landmark = ListLandmarks.FetchLandmarks.Response.Landmark

protocol ListLandmarksPresentationPreparer {
    func presentLandmarks(response: ListLandmarks.FetchLandmarks.Response)
}

class ListLandmarksInteractor {
    var presenter: ListLandmarksPresentationPreparer?
    
    var mountains: [Mountain] = []
}

extension ListLandmarksInteractor: ListLandmarksRequestable {
    func fetchLandmarks(request: ListLandmarks.FetchLandmarks.Request) {
        mountains = SimpleData_Mountains.mountains
        let landmarks = mountains.enumerated().map({ $1.landmark(withIndex: $0) })
        presenter?.presentLandmarks(response: ListLandmarks.FetchLandmarks.Response(landmarks: landmarks))
    }
}

extension ListLandmarksInteractor: ListLandmarksDataStorer {
    func mountain(forIndex index: Int) -> Mountain? {
        guard mountains.indices.contains(index) else {
            return nil
        }
        return mountains[index]
    }
}

fileprivate extension Mountain {
    func landmark(withIndex index: Int) -> Landmark {
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                  altitude: altitude, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date())
        return Landmark(name: name, location: location, index: index)
    }
}
