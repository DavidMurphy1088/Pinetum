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
                    Label("GPSRead", image: "compassIcon")
                }

            LocationsView()
                .tabItem {
                    Label("Distances", image: "listIcon")
                    //Image("listIcon").frame(width: 5, height: 5)
                }
        }
    }
}

struct GPSReadView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var locationManager = LocationManager.shared
    @State private var savePopup = false
    @State private var savePopup1 = false
    @State private var locationName: String = ""
    @State private var addDirections = false
    
    func fmt(_ l: CLLocationCoordinate2D) -> String {
        return String(format: "%.5f", l.latitude)+",  "+String(format: "%.5f", l.longitude)
    }
    
    func saveForm(cords:CLLocationCoordinate2D) -> some View {
        Form {
            VStack {
                VStack(alignment: .center) {
                    Text("Save Location").font(.title2).bold()
                    TextField("name of location", text: $locationName)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .padding()
//                    Toggle("Add Directions?", isOn: $addDirections)
//                        .padding()
                }
                
                HStack {
                    Spacer()
                    Button("Cancel") {
                        savePopup = false
                    }
                    Spacer()
                    Button("Save") {
                        let rec = LocationRecord(name: locationName,
                                                 lat: cords.latitude,
                                                 lng: cords.longitude)
                        self.locationManager.saveLocation(rec: rec)
                        
//                        if false && addDirections {
//                            let delta = 0.0002
//                            rec = LocationRecord(name: locationName+"_NE",
//                                                 lat: l.latitude + delta,
//                                                 lng: l.longitude + delta)
//                            self.locationManager.saveLocation(rec: rec)
//                            rec = LocationRecord(name: locationName+"_NW",
//                                                 lat: l.latitude + delta,
//                                                 lng: l.longitude - delta)
//                            self.locationManager.saveLocation(rec: rec)
//                            rec = LocationRecord(name: locationName+"_SE",
//                                                 lat: l.latitude - delta,
//                                                 lng: l.longitude + delta)
//                            self.locationManager.saveLocation(rec: rec)
//                            rec = LocationRecord(name: locationName+"_SW",
//                                                 lat: l.latitude - delta,
//                                                 lng: l.longitude - delta)
//                            self.locationManager.saveLocation(rec: rec)
//                        }
                        locationManager.resetLastStableLocation()
                        savePopup = false
                    }
                    Spacer()
                }
            }
        }
    }
    
    func saveLocation() -> some View {
        VStack {
            VStack(alignment: .leading) {
                Button("Save Location") {
                    savePopup.toggle()
                }
            }
            .popover(isPresented: $savePopup) {
                saveForm(cords: locationManager.lastStableLocation!)
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Current Location").font(.title2).bold()
            if let message = locationManager.status.message {
                Text(message)
            }

            if locationManager.currentLocation == nil {
                Spacer()
                Text("Start Location Manager")
                LocationButton {
                    locationManager.requestLocation()
                }
                .symbolVariant(.fill)
                .labelStyle(.titleAndIcon)
                //Spacer()
                //                        Spacer()
                //                        Button("Test Start") {
                //                            locationManager.requestLocation()
                //                        }
            }
//            Spacer()
//            Button("Test Google API") {
//                locationManager.googleAPI()
//            }
            Spacer()
            Button("Save Location") {
                savePopup.toggle()
            }
            .disabled(locationManager.lastStableLocation == nil)
            .popover(isPresented: $savePopup) {
                saveForm(cords: locationManager.lastStableLocation!)
            }
            //saveLocation().disabled(locationManager.lastStableLocation == nil)
            
            Spacer()
            Button("Reset Location Manager") {
                locationManager.reset()
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

