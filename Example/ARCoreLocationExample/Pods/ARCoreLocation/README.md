# ARCoreLocation

ARCoreLocation is a lightweight and configurable iOS framework for displaying AR content at real-world coordinates.

## Features:
• Easily create AR scenes that place AR objects in the real world

• Place AR objects at any geographic location without worrying about ARKit's implementation details

• Receive tap events on your AR content

• Receive events when AR content overlaps on-screen


## Installation

### CocoaPods
Enter this in your Podfile:
```
pod 'ARCoreLocation', '~> 0.1.9'
```
Then run `pod install`. Remember to `import ARCoreLocation` in any file where you want to use it!

## Usage

### Setup

Create the ARLandmarker and add its view:
```Swift
let landmarker = ARLandmarker(view: ARSKView(), scene: InteractiveScene(), locationManager: CLLocationManager())
landmarker.view.frame = self.view.bounds
landmarker.scene.size = self.view.bounds.size
self.view.addSubview(landmarker.view)
```

Add Landmarks to the scene:
```Swift
let landmarkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 20))
landmarkLabel.text = "Statue of Liberty"
let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 40.689234, longitude: -74.044524), altitude: 30, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
landmarker.addLandmark(view: landmarkLabel, at: location, completion: nil)
```

### User Interaction

Get User Interaction events:
```Swift
landmarker.delegate = self

...

extension ViewController: ARLandmarkerDelegate {
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didTap landmark: ARLandmark) {
        ...
    }
    
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didFailWithError error: Error) -> Void {
        ...
    }
}
```
### Overlapping Landmarks

Use different strategies for overlapping landmarks:
```Swift
landmarker.overlappingLandmarksStrategy = .showAll
landmarker.overlappingLandmarksStrategy = .showNearest
landmarker.overlappingLandmarksStrategy = .showFarthest
landmarker.overlappingLandmarksStrategy = .custom(callback: { (overlappingLandmarkGroups, notOverlappingLandmarks) in
    // Check overlapping groups and react accordingly
})
```

Request the landmarker to check for overlapping landmarks at a given interval:
```Swift
// Check for overlaps every second
landmarker.beginEvaluatingOverlappingLandmarks(atInterval: 1)
...
landmarker.stopEvaluatingOverlappingLandmarks()
```

Or check for overlapping landmarks immediately 
```Swift
// ... Or check immediately
landmarker.evaluateOverlappingLandmarks()
```
