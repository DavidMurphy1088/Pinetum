import SwiftUI
import CoreData
import CoreLocation
import CoreLocationUI
import CoreLocation
import UIKit

struct ContentView: View {
    var body: some View {
        TabView {
            GPSReadView()
                .tabItem {
                    Label("GPSRead", systemImage: "xmark.circle")
                }

            DistancesView()
                .tabItem {
                    Label("Distances", systemImage: "xmark.rectangle")
                }
        }
    }
}

struct GPSReadView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var locationManager = LocationManager.shared
    @State private var savePopup = false
    @State private var locationName: String = ""
    
    func fmt(_ l: CLLocationCoordinate2D) -> String {
        return String(format: "%.5f", l.latitude)+",  "+String(format: "%.5f", l.longitude)
    }
    
    func saveLocation() -> some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                Button("Save Location") {
                    savePopup.toggle()
                }
            }.popover(isPresented: $savePopup) {
                VStack {
                    VStack(alignment: .center) {
                        Text("Save Location").font(.title3)
                        Text("\n"+locationManager.status+"\n")
                        TextField("location", text: $locationName)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                    }
                    HStack {
                        Spacer()
                        Button("Cancel") {
                            savePopup = false
                        }
                        Spacer()
                        Button("Save") {
                            if let l = locationManager.currentLocation {
                                var rec = LocationRecord(name: locationName,
                                                         lat: l.latitude - 0.00000,
                                                         lng: l.longitude -  0.0)
                                self.locationManager.saveLocation(rec: rec)
                                
                                if false {
                                    // home -41.0     174.0
                                    rec = LocationRecord(name: "South",
                                                         lat: -41.1,
                                                         lng: 174.0)
                                    
                                    self.locationManager.saveLocation(rec: rec)
                                    rec = LocationRecord(name: "East",
                                                         lat: -41.0,
                                                         lng: 174.1)
                                    self.locationManager.saveLocation(rec: rec)
                                    rec = LocationRecord(name: "West",
                                                         lat: -41.0,
                                                         lng: 173.9)
                                    self.locationManager.saveLocation(rec: rec)
                                    rec = LocationRecord(name: "North",
                                                         lat: -39.9,
                                                         lng: 174.0)
                                    self.locationManager.saveLocation(rec: rec)
                                    
                                    rec = LocationRecord(name: "NE",
                                                         lat: -39.9,
                                                         lng: 174.1)
                                    self.locationManager.saveLocation(rec: rec)
                                    rec = LocationRecord(name: "NW",
                                                         lat: -39.9,
                                                         lng: 173.9)
                                    self.locationManager.saveLocation(rec: rec)
                                    
                                    rec = LocationRecord(name: "SE",
                                                         lat: -41.1,
                                                         lng: 174.1)
                                    self.locationManager.saveLocation(rec: rec)
                                    
                                    rec = LocationRecord(name: "SW",
                                                         lat: -41.1,
                                                         lng: 173.9)
                                    self.locationManager.saveLocation(rec: rec)
                                }
                            }
                            savePopup = false
                        }
                        Spacer()
                    }
                }
                .frame(width: 300, height: 300, alignment: .center)
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                if let location = locationManager.currentLocation {
                    Spacer()
                    Text("Location:").font(.title3)
                    Text(fmt(location)).font(.title3)
                    Text("\n"+locationManager.status)
                }
            }

            VStack {
                if locationManager.currentLocation == nil {
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            Text("Start Location->")
                            LocationButton {
                                locationManager.requestLocation()
                            }
                            Spacer()
                        }
                    }
                }
            }
            
            saveLocation()
                .disabled(locationManager.currentLocation == nil)
            
            VStack {
                Spacer()
                VStack {
                    VStack(alignment: .leading) {
                        Button("Reset Location Manager") {
                            locationManager.reset()
                        }
                    }
                }
                Spacer()
                //Text(self.status)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

