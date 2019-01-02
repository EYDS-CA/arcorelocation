//
//  OverlappingARLandmarkStrategy.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import Foundation

/// The strategy to employ when ARLandarks appear overlapping
public enum OverlappingARLandmarkStrategy {
    /// Display all the landmarks, unchanged
    case showAll
    /// Hide all but the nearest of the overlapping landmarks
    case showNearest
    /// Hide all but the farthest of the overlapping landmarks
    case showFarthest
    /// Perform some custom action
    case custom(callback: (_ overlapping: [[ARLandmark]], _ independent: [ARLandmark]) -> Void)
}
