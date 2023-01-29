import Foundation
import CoreLocation
import MapKit

class LocationRecord: Codable, Hashable, Comparable {
    var name = ""
    var latitude:Double = 0
    var longitude:Double = 0
    var datetime:TimeInterval = 0
    
    init(name: String, lat: Double, lng: Double) {
        self.name = name
        self.latitude = lat
        self.longitude = lng
        self.datetime = Date().timeIntervalSince1970
    }

    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        datetime = try values.decode(TimeInterval.self, forKey: .datetime)
    }
        
    static func < (lhs: LocationRecord, rhs: LocationRecord) -> Bool {
        if lhs.name < rhs.name {
            return true
        }
        else {
            return lhs.datetime < rhs.datetime
        }
    }
    
    static func == (lhs: LocationRecord, rhs: LocationRecord) -> Bool {
        return lhs.name == rhs.name && lhs.datetime == rhs.datetime
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name + String(self.datetime))
    }
}

extension LocationRecord: Identifiable {
  var id: Double { datetime }
}

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published public var locations : [LocationRecord] = []
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published public var status: String = ""

    static public let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private var cnt = 0
    private var lastLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self

        switch locationManager.accuracyAuthorization {
        case .fullAccuracy:
            print("Full Accuracy")
        case .reducedAccuracy:
            print("Reduced Accuracy")
        @unknown default:
            print("Unknown Precise Location...")
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locations = []
        if let data = UserDefaults.standard.data(forKey: "GPSData") {
            if let decoded = try? JSONDecoder().decode([LocationRecord].self, from: data) {
                locations = decoded
            }
        }
//        self.distanceFilter = CLLocationDistance()
//        self.pausesLocationUpdatesAutomatically = false
//        self.allowsBackgroundLocationUpdates
        
        setStatus("Loaded locations, length \(self.locations.count)")
    }
    
    func setStatus(_ msg: String) {
        DispatchQueue.main.async {
            self.status = msg
        }
    }
    
    func requestLocation() {
        self.setStatus("Requested Continous Locations")
        self.cnt = 0
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async { [self] in
            self.lastLocation = self.currentLocation
            self.currentLocation = location.coordinate

            self.cnt += 1
            var dist = -1.0
            if let last = self.lastLocation {
                if let cur = self.currentLocation {
                    dist = self.distance(startLat: last.latitude, startLng: last.longitude,
                                             endLat: cur.latitude, endLng: cur.longitude)
                }
            }
            self.setStatus("Updated Location, count:\(cnt) dist:" + String(format: "%.4f",dist))
        }
    }
    
    func saveLocation(rec: LocationRecord) {
        DispatchQueue.main.async {
        self.locations.append(rec)
        if let encoded = try? JSONEncoder().encode(self.locations) {
            UserDefaults.standard.set(encoded, forKey: "GPSData")
        }
        
//            self.locationsDisplay = self.locations.sorted {
//                if $0.name > $1.name {
//                    return true
//                }
//                else {
//                    return $0.datetime > $1.datetime
//                }
//            }
            self.setStatus("saved length \(self.locations.count)")
        }
        self.currentLocation = nil
        locationManager.stopUpdatingLocation()
    }
    
    func reset() {
        self.setStatus("Resetting Location")
        self.cnt = 0
        locationManager.stopUpdatingLocation()
        self.currentLocation = nil
        self.lastLocation = nil
    }

    func clearList() {
        self.locations.removeAll()
        UserDefaults.standard.removeObject(forKey: "GPSData")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        setStatus(error.localizedDescription)
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    func distance(startLat: Double, startLng:Double, endLat: Double, endLng:Double) -> Double {
        //=1000*ACOS(COS(RADIANS(90-C3))*COS(RADIANS(90-E3))+SIN(RADIANS(90-C3))*SIN(RADIANS(90-E3))*COS(RADIANS(D3-F3)))*6371

        var p1 = (-39.88588889,  175.9621667) // 90 metres cottage to gate
        var p2 = (-39.88597222,  175.9611111)
//        p1 = (-41.27847, 174.76829)
//        p2 = (-41.27853, 174.76849)
        p1 = (startLat, startLng)
        p2 = (endLat, endLng)
        
        var cx = 90 - p1.0
        cx = deg2rad(cx)
        cx = cos(cx)

        var cy = 90 - p2.0
        cy = deg2rad(cy)
        cy = cos(cy)

        var sx = 90 - p1.0
        sx = deg2rad(sx)
        sx = sin(sx)
        
        var sy = 90 - p2.0
        sy = deg2rad(sy)
        sy = sin(sy)
        
        var cz = p1.1 - p2.1
        cz = deg2rad(cz)
        cz = cos(cz)

        var r = (cx*cy) + (sx*sy*cz)
        r = acos(r)
        return r * 6371 * 1000
    }

}
