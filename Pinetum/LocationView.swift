import Foundation
import SwiftUI
import CoreData
import CoreLocation
import CoreLocationUI
import CoreLocation
import UIKit

struct LocationView: View {
    //http://dwtkns.com/pointplotter/
    @ObservedObject var locationRecord:LocationRecord
    @ObservedObject var locationManager = LocationManager.shared
    @Environment(\.scenePhase) private var scenePhase

    @State private var angle = 0.0
    @State private var savePopup = false
    
    func saveForm(cords:CLLocationCoordinate2D) -> some View {
        Form {
            VStack {
                VStack(alignment: .center) {
                    Text("Save Location Revisit").font(.title2).bold()
                    if let message = locationManager.status.message {
                        Text("\n"+message+"\n").foregroundColor(.gray)
                    }
                }
                HStack {
                    Spacer()
                    Button("Cancel") {
                        savePopup = false
                    }
                    Spacer()
                    Button("Save") {
                        let revisitRecord = RevisitRecord()
                        let dist = locationManager.distance(startLat:locationRecord.latitude,
                                                            startLng:locationRecord.longitude,
                                                            endLat: cords.latitude,
                                                            endLng: cords.longitude)
                        revisitRecord.distanceFromOriginalLocation = dist
                        locationRecord.addRevisit(rec: revisitRecord)
                        locationManager.persistLocations()
                        locationManager.resetLastStableLocation()
                        savePopup = false
                    }
                    .disabled(locationManager.lastStableLocation == nil)
                    Spacer()
                }
            }
        }
    }
    
    func saveRevisitView(saveLocation:CLLocationCoordinate2D?) -> some View {
        VStack {
            VStack(alignment: .leading) {
                Button("Save Location Revisit") {
                    savePopup.toggle()
                }
                .padding()
                .disabled(saveLocation == nil)
            }.popover(isPresented: $savePopup) {
                if let loc = saveLocation {
                    saveForm(cords: loc)
                }
            }
        }
    }

    func revisitLine(rec : RevisitRecord) -> String {
        var ret = locationManager.fmtDatetime(datetime: rec.datetime)
        ret += " distance:"+String(format: "%.1f",rec.distanceFromOriginalLocation)
        return ret
    }
    
    func delete(at offsets: IndexSet) {
        locationRecord.revisits.remove(atOffsets: offsets)
    }

    var body: some View {
        VStack {
            Text("Location:" + locationRecord.name).font(.title2).bold()
            Text("Location at:"+String(format: "%.4f",locationRecord.latitude) + ",  " + String(format: "%.4f", locationRecord.longitude))
            Text("Distance from current location:" + String(format: "%.1f",distance()))
            if let message = locationManager.status.message {
                Text(message).font(.caption)
            }

            Image("pointer")
            .resizable()
            .rotationEffect(.degrees(bearing()))
            .animation(.easeIn, value: bearing())

            List {
                Text("Saved revisits to this location").font(.title3).bold()
                ForEach(locationRecord.revisits, id: \.datetime) { revisit in
                    Text(self.revisitLine(rec: revisit))
                }
                .onDelete(perform: delete)
            }
            
            saveRevisitView(saveLocation: locationManager.lastStableLocation)
        }
    }
    
    func DegreesToRadians(_ degrees: Double ) -> Double {
        return degrees * Double.pi / 180
    }

    func RadiansToDegrees(_ radians: Double) -> Double {
        return radians * 180 / Double.pi
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

        let y = sin(locationRecord.longitude-currentLong) * cos(locationRecord.latitude);
        let x = cos(currentLat)*sin(locationRecord.latitude) -
           sin(currentLat)*cos(locationRecord.latitude)*cos(locationRecord.longitude-currentLong);
        let radians = atan2(y, x);
        //let brng = (theta*180/Double.pi + 360) % 360; // in degrees
        let brng = radians * 180 / Double.pi
        return 0 - brng
    }
        
    func bearing() -> Double {
        var res:Double = 0
        if let loc = locationManager.currentLocation {
            res =  bearingToLocationDegrees(currentLat: loc.latitude, currentLong: loc.longitude)
            res += angle
            //res *= -1
            //print("===Heading", loc.latitude, loc.longitude,  " to ", locationRecord.latitude, locationRecord.longitude, " dir:", res)
        }
        else {
            res = 0
        }
        return res
    }
    
    func distance() -> Double {
        if let cur = locationManager.currentLocation {
            return locationManager.distance(startLat:locationRecord.latitude, startLng:locationRecord.longitude,
                                            endLat: cur.latitude, endLng: cur.longitude)
        }
        else {
            return 0
        }
    }
    

}
