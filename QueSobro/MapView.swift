//  MapView.swift
//  QueSobro
//
//  Created by Fernando Martínez on 29/03/25.
//
import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

struct MapView: View {
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Constancia con el app
    let staticBlueColor = Color.blue
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161), // Centro en Monterrey
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @StateObject private var locationManager = LocationManager()
    @State private var locations: [BusinessLocation] = [
            // Punto azul estático añadido aquí
            BusinessLocation(
                name: "Mi ubicación",
                coordinate: CLLocationCoordinate2D(
                    latitude: 25.65098,
                    longitude: -100.28937
                )
            )
        ]
    // olvidalo no fue necesaerio lol: @State private var nombresS: [String] = [] // A ver si jala esto lol : EDIT PARA FUTURO, NO USES BUSINESSLOCATION, DEJALO EN STRING AQUI !

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true,annotationItems: locations) { location in
               MapAnnotation(coordinate: location.coordinate) {
                   VStack {
                       Text(location.name)
                           .font(.subheadline.weight(.bold))
                           .foregroundColor(.black)
                           .background()
                       Image(systemName: "mappin.circle.fill").foregroundColor(location.name == "Mi ubicación" ? staticBlueColor : primaryColor)
                   }
               }
           }
        .onAppear {
            
            locationManager.requestAuthorization()
    
            fetchBusinesses()
        }
    }
    

    func fetchBusinesses() {
        let db = Firestore.firestore()
        db.collection("comercios").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error obteniendo con los documentos")
                return
            }

            for document in documents {
                if let address = document.data()["direccion"] as? String {
                    let nombre = document.data()["nombre"] as! String // para que el nombrecillo aparezca debajo de los puntos!
                    geocodeUsingApple(address: address) { coordinate in
                        if let coordinate = coordinate {
                            let newLocation = BusinessLocation(name: nombre, coordinate: coordinate)
                            DispatchQueue.main.async {
                                self.locations.append(newLocation)
                            }
                        }
                    }
                }
            }
        }
    }

    func geocodeUsingApple(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                completion(location.coordinate)
            } else {
                print("No se pudo geocodificar la dirección: \(address)")
                completion(nil)
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation() // Start updating location once authorized
        case .denied, .restricted:
            print("Location access denied or restricted")
        case .notDetermined:
            print("Location authorization not yet determined")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
}

struct BusinessLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}


struct MapViewPreviews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
