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
    
    var places: [VictoriaLandmark] = []
}

extension ListLandmarksInteractor: ListLandmarksRequestable {
    func fetchLandmarks(request: ListLandmarks.FetchLandmarks.Request) {
        places = VictoriaData_Landmarks.landmarks
        let landmarks = places.enumerated().map({ $1.landmark(withIndex: $0) })
        presenter?.presentLandmarks(response: ListLandmarks.FetchLandmarks.Response(landmarks: landmarks))
    }
}

extension ListLandmarksInteractor: ListLandmarksDataStorer {
    func place(forIndex index: Int) -> VictoriaLandmark? {
        guard places.indices.contains(index) else {
            return nil
        }
        return places[index]
    }
}

//fileprivate extension Mountain {
//    func landmark(withIndex index: Int) -> Landmark {
//        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
//                                  altitude: altitude, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date())
//        return Landmark(name: name, location: location, index: index)
//    }
//}

fileprivate extension VictoriaLandmark {
    func landmark(withIndex index: Int) -> Landmark {
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                  altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date())
        return Landmark(name: name, location: location, details: details, index: index)
    }
}
