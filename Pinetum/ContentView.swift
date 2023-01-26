import SwiftUI
import CoreData
import CoreLocation
import CoreLocationUI
import CoreLocation
import UIKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showDetails = false
    @ObservedObject var locationManager = LocationManager()
    @State private var continuous = false
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    func dist() -> Double {
        let p1 = (-39.88588889,  175.9621667)
        //let p2 = (-39.88597222,  175.9611111)
        let p2 = (-39.88589889,  175.9621667)

        var cx = 90 - p1.0
        cx = deg2rad(cx)
        cx = cos(cx)

        var cy = 90 - p2.0
        cy = deg2rad(cy)
        cy = cos(cy)
        
        //----
        
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
        //=1000*ACOS(COS(RADIANS(90-C3))*COS(RADIANS(90-E3))+SIN(RADIANS(90-C3))*SIN(RADIANS(90-E3))*COS(RADIANS(D3-F3)))*6371
    }
    
    func fmt(_ l: CLLocationCoordinate2D) -> String {
        return String(format: "%.5f", l.latitude)+",  "+String(format: "%.5f", l.longitude)
    }
    
    var body: some View {

        VStack {
            Spacer()
            if continuous {
                if let l = locationManager.location {
                    Text("GPS "+fmt(l)).font(.title3)
                }
            }
            if let location = locationManager.location {
                Text("Your location:").font(.title3)
                Text(fmt(location)).font(.title3)
            }

            Spacer()
            LocationButton {
                print("button2")
                locationManager.requestLocation()
            }
            .frame(height: 22)
            .padding()
            Spacer()
            Button("Continuous") {
                continuous.toggle()
                locationManager.makeContinuous(way: continuous)
            }
            Spacer()
            Button("Distance") {
                let d = dist()
                print("dist meters", String(format: "%.2f", d))
            }
            Spacer()
        }
    }
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

