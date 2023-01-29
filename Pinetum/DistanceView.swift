import Foundation
import SwiftUI
import CoreData
import CoreLocation
import CoreLocationUI
import CoreLocation
import UIKit

struct DistancesView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @State private var isPresentingConfirm = false
    
    func locLine(rec:LocationRecord) -> String {
        let now = Date(timeIntervalSince1970:rec.datetime)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM-dd HH:mm"
        let dateString = formatter.string(from: now)

        var ret = rec.name + "\t\t" + dateString +
        "\nlat:" + String(format: "%.5f", rec.latitude) +
        " lng:" + String(format: "%.5f", rec.longitude)
        if let loc = locationManager.currentLocation {
            ret += " dist:" + String(format: "%.1f",
                                     locationManager.distance(startLat:rec.latitude, startLng:rec.longitude,
                                                              endLat: loc.latitude,
                                                              endLng: loc.longitude))
        }
        return ret
    }
    
    var body: some View {
        VStack {
            Text("Distances")
//            List(locationManager.locationsDisplay, id: \.self.datetime) {
//                Text(locLine(rec: $0))//.font(.footnote)
////                ForEach(locationManager.locations, id: \.id) { result in
////                    Text("Result: \(result.name)")
////                }
//            }
            List {
                ForEach(locationManager.locations.sorted(), id: \.self) { loc in
                    Text(locLine(rec: loc))

                }
            }
                    
            Button("Clear List", role: .destructive) {
                  isPresentingConfirm = true
            }
           .confirmationDialog("Are you sure?",
                isPresented: $isPresentingConfirm) {
                Button("Delete all items?", role: .destructive) {
                    locationManager.clearList()
                }
            }
        }
    }
}
