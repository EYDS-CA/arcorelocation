//
//  ARLandmarkDisplayer.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import CoreLocation
import ARKit

/// A callback to indicate when the addition of an ARLandmark has finished processing
/// - parameter landmark: The data representing the landmark in the AR World
public typealias LandmarkCallback = (_ landmark: ARLandmark?) -> Void

public protocol ARLandmarkDisplayer {
    /// The view on which to project the AR content
    var view: ARSKView { get }
    
    /// The distance, in meters, the device can travel away from the last world origin before a new world origin is calculated. It is a programmer error to set this to more than 100.
    var worldRecenteringThreshold: Double { get set }
    
    /// The smallest scaling factor that should be applied to the AR views.
    var minViewScale: CGFloat { get set }
    
    /// The nearest distance, in meters, at which AR views should appear at `minViewScale`.
    var maxViewScaleDistance: Double { get set }
    
    /// The nearest distance at which AR views will be shown.
    var minumumVisibleDistance: Double { get set }
    
    /// The farthest distance at which AR views will be shown.
    var maximumVisibleDistance: Double { get set }
    
    /// The strategy to employ when ARLandarks overlap.
    var overlappingLandmarksStrategy: OverlappingARLandmarkStrategy { get set }
    
    /// Add an image into the AR World
    /// - parameter image: The image to add to the AR World
    /// - parameter location: The real-world location at which the image should be displayed
    /// - parameter completion: Called when the view has been added.
    func addLandmark(image: UIImage, at location: CLLocation, completion: LandmarkCallback?) -> Void
    
    /// Add a view into the AR World.
    /// - parameter view: The view to add to the AR World. It will be interpreted as a static image.
    /// - parameter location: The real-world location at which the view should be displayed
    /// - parameter completion: Called when the view has been added.
    func addLandmark(view: UIView, at location: CLLocation, completion: LandmarkCallback?) -> Void
    
    /// Remove all landmarks from the AR World
    func removeAllLandmarks() -> Void
    
    /// Remove a landmark from the AR World.
    /// - parameter landmark: The landmark to remove.
    /// - returns: `true` if the landmark existed and was removed, `false` if the landmark did not exist.
    func remove(landmark: ARLandmark) -> Bool
}

public protocol ARLandmarkDisplayerDelegate: class {
    /// Called when the user taps an ARLandmark
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarkDisplayer, didTap landmark: ARLandmark) -> Void
    
    /// Called when something causes the landmark displayer to fail
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarkDisplayer, didFailWithError error: Error) -> Void
}
