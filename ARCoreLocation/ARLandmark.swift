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
    /// The info for this landmark. Landmark userInfo is for convenience, and is never displayed to the user.
    public let userInfo: [String: Any]
    /// The displayable image
    public let image: UIImage
    /// The real-world location where the landmark is displayed
    public let location: CLLocation
    /// The id of the landmark in the AR World
    internal let id: UUID
}
