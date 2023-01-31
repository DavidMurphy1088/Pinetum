import Foundation
import SwiftUI
import CoreData
import CoreLocation
import CoreLocationUI
import CoreLocation
import UIKit

struct DistancesView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var locationManager = LocationManager.shared
    @State private var isPresentingConfirm = false
    
    func locLine(rec:LocationRecord) -> String {
        let now = Date(timeIntervalSince1970:rec.datetime)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM-dd HH:mm"
        let dateString = formatter.string(from: now)

        var ret = rec.name + "\t\t" + dateString 
        //"\nlat:" + String(format: "%.5f", rec.latitude) +
        //" lng:" + String(format: "%.5f", rec.longitude)
        if let loc = locationManager.currentLocation {
            ret += " dist:" + String(format: "%.1f",
                                     locationManager.distance(startLat:rec.latitude, startLng:rec.longitude,
                                                              endLat: loc.latitude,
                                                              endLng: loc.longitude))
        }
        return ret
    }
    
    func delete(at offsets: IndexSet) {
        locationManager.locations.remove(atOffsets: offsets)
    }
    
    var body: some View {
        VStack {
            Text("Distances")
            Text(locationManager.status)
            NavigationStack {
                Text("Swipe row left to delete").foregroundColor(.gray)
                List {
                    ForEach(locationManager.locations.sorted(), id: \.self) { loc in
                        NavigationLink(value: loc, label: {
                        Text(locLine(rec: loc)).font(.system(size: 18))
                                .font(.subheadline.weight(.medium))
                        })
                    }
                    .onDelete(perform: delete)
                }
                .navigationDestination(for: LocationRecord.self, destination: { loc in
                    LocationView(locationRecord: loc)
                            })
                .navigationTitle(Text("Locations"))
            }

            Button("Clear List", role: .destructive) {
                  isPresentingConfirm = true
            }
           .confirmationDialog("Are you sure?",
                isPresented: $isPresentingConfirm) {
                Button("Delete all locations?", role: .destructive) {
                    locationManager.clearList()
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    locationManager.persistLocations()
                }
            }
        }
    }
}
