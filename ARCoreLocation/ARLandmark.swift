//
//  ARLandmark.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import CoreLocation
import UIKit

/// A representation of a landmark in an AR World
public struct ARLandmark {
    /// The displayable image
    public var image: UIImage
    /// The real-world location where the landmark is displayed
    public var location: CLLocation
    /// The id of the landmark in the AR World
    public var id: UUID
}
