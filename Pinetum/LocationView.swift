import Foundation
import SwiftUI
import CoreData
import CoreLocation
import CoreLocationUI
import CoreLocation
import UIKit

struct LocationView: View {
    @State var locationRecord:LocationRecord
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var locationManager = LocationManager.shared
    @State private var angle = 0.0

    func DegreesToRadians(_ degrees: Double ) -> Double {
        return degrees * M_PI / 180
    }

    func RadiansToDegrees(_ radians: Double) -> Double {
        return radians * 180 / M_PI
    }

    func bearingToLocationRadian1(srcLat:Double, srcLong:Double) -> Double {
        //house             -41.27835695935406, 174.76827635559158
        //well              -41.2924  174.7787
        //well east coast   -41.2634, 175.8878
        //far east          -41.3915, 178.2385
        
        //west coast        -41.2773, 174.6222
        //south west        -42.1333, 172.7399
        //far west          -41.1189, 170.1745
        
        
        let lat1 = srcLat
        let lon1 = srcLong

        //let lat2 = DegreesToRadians(destinationLocation.coordinate.latitude);
        //let lon2 = DegreesToRadians(destinationLocation.coordinate.longitude);
        
        let lat2 = locationRecord.latitude
        let lon2 = locationRecord.longitude

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x)

        return radiansBearing
    }

    func bearingToLocationDegrees(currentLat:Double, currentLong:Double) -> Double {
        //θ = atan2( sin Δλ ⋅ cos φ2 , cos φ1 ⋅ sin φ2 − sin φ1 ⋅ cos φ2 ⋅ cos Δλ )
        //where    φ1,λ1 is the start point, φ2,λ2 the end point (Δλ is the difference in longitude)
        //1 = current, 2 = location record
        
//        const y = Math.sin(λ2-λ1) * Math.cos(φ2);
//        const x = Math.cos(φ1)*Math.sin(φ2) -
//                  Math.sin(φ1)*Math.cos(φ2)*Math.cos(λ2-λ1);
//        const θ = Math.atan2(y, x);
//        const brng = (θ*180/Math.PI + 360) % 360; // in degrees
        
        let y = sin(locationRecord.longitude-currentLong) * cos(locationRecord.latitude);
        let x = cos(currentLat)*sin(locationRecord.latitude) -
           sin(currentLat)*cos(locationRecord.latitude)*cos(locationRecord.longitude-currentLong);
        let radians = atan2(y, x);
        //let brng = (theta*180/Double.pi + 360) % 360; // in degrees
        let brng = radians * 180 / Double.pi
        return 0 - brng
    }
    
//    func bearingToLocationDegrees(currentLat:Double, currentLong:Double) -> Double{
//        return  RadiansToDegrees(bearingToLocationRadian(currentLat: currentLat, currentLong: currentLong))
//    }
    
    func bearing() -> Double {
        //return 34 + angle
        var res:Double = 0
        if let loc = locationManager.currentLocation {
            res =  bearingToLocationDegrees(currentLat: loc.latitude, currentLong: loc.longitude)
            //res *= -1
            //print("===Heading", loc.latitude, loc.longitude,  " to ", recordLocation.latitude, recordLocation.longitude, " dir:", res)
        }
        else {
            res = 0
        }
        return res + angle
    }
    
    func distance() -> Double {
        if let cur = locationManager.currentLocation {
        return locationManager.distance(startLat:locationRecord.latitude, startLng:locationRecord.longitude,
                                        endLat: cur.latitude,
                                        endLng: cur.longitude)
        }
                                        else {
            return 0
        }
                                        
    }
    var body: some View {
        VStack {
            Text(locationRecord.name)
            Text(String(locationRecord.latitude) + "  " + String(locationRecord.longitude))
            Text("Distance:" + String(String(format: "%.1f",distance())))
            Image("pointer")
                .resizable()
                .frame(width: 256.0, height: 256.0)
                .rotationEffect(.degrees(bearing()))
                .animation(.easeIn, value: bearing())
            Button("Rotate") {
                angle += 10
            }
        }
    }
}
