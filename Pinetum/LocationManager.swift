import Foundation
import CoreLocation
import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    public var cnt = 0

    @Published var location: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.0422448, longitude: -102.0079053),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        print("requestLocation()")
        locationManager.requestLocation()
    }

    func makeContinuous(way: Bool) {
        if way {
            locationManager.startUpdatingLocation()
        }
        else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("didUpdateLocations", cnt)
        guard let location = locations.first else { return }
        DispatchQueue.main.async { [self] in
            self.location = location.coordinate
            //print("didUpdateLocations queue", cnt, self.location?.latitude)
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            self.cnt += 1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print (error, error.localizedDescription)
    }
}
