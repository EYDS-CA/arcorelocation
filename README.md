# ARCoreLocation

## Usage

```
import ARKit
import ARCoreLocation

// Create the ARLandmarker and add its view as a subview
let landmarker = ARLandmarker(view: ARSKView(), scene: InteractiveScene(), locationManager: CLLocationManager())
landmarker.view.frame = self.view.bounds
landmarker.scene.size = self.view.bounds.size
self.view.addSubview(landmarker.view)

// Add landmarks
let landmarkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 20))
landmarkLabel.text = "Statue of Liberty"
let location = CLLocation(latitude: 40.689234, longitude: -74.044524)
CLLocation(coordinate: CLLocationCoordinate2D(latitude: 40.689234, longitude: -74.044524), altitude: 30, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
landmarker.addLandmark(view: landmarkLabel, at: location, completion: nil)
```
