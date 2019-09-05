//
//  ListLandmarksModels.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit
import CoreLocation

enum ListLandmarks {
    // MARK: Use cases
    enum FetchLandmarks {
        struct Request { }
        
        struct Response {
            struct Landmark {
                let name: String
                let location: CLLocation
                let details: String?
                let index: Int
            }
            let landmarks: [Landmark]
        }
        
        struct ViewModel {
            struct Landmark {
                let name: String
//                let altitude: String
                let location: CLLocation
                let details: String?
                let index: Int
            }
            let landmarks: [Landmark]
        }
    }
}
