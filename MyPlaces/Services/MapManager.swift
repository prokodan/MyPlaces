//
//  MapManager.swift
//  MyPlaces
//
//  Created by Данил Прокопенко on 20.10.2022.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    private let regionInMeters = 1_000.00
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    //MARK: - Private Methods
    
    //Setup Pin of place
     func setupPlaceMark(place: Place, mapView: MKMapView) {
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
     func checkLocationServices(mapView: MKMapView, segueIdentifier: String, completion: () -> Void) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            completion()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services disabled", message: "To enable location services go to Settings -> Privacy and security -> Location services and turn on")
            }
        }
    }
 
    //Checking geolocation services availability
     func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" {showUserLocation(mapView: mapView)}
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Geolocation is denied", message: "To enable location services go to Settings -> Privacy and security -> \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "AppName") and allow location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Geolocation is restricted", message: "To enable location services go to Settings -> Privacy and security -> \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "AppName") and allow location")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }

    //Focusing map at user location
     func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
     func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> Void) {
        guard let location = locationManager.location?.coordinate else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Error", message: "Current location is not found")
            }
            return
        }
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        guard let request = createDirectionsRequest(from: location) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Error", message: "Destination is not found")
            }
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let response = response else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showAlert(title: "Error", message: "Direction is not available")
                }
                return
            }
            if response.routes.capacity == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showAlert(title: "Error", message: "No routes available for current location")
                }
            }  else {
                
                for route in response.routes {
                    mapView.addOverlay(route.polyline)
                    mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    
                    let distance = String(format: "%.1f",route.distance / 1000 )
                    let timeInterval = String(format: "%.0f",route.expectedTravelTime / 60 )
                    
                    print("Расстояние до места: \(distance) км.")
                    print("время в пути составит: \(timeInterval) сек.")
                }
            }
        }
    }
    
    //Setup request for route calculation
     func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    //Change map visible zone depending on user location
     func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, completion: (_ currentLocation:CLLocation) -> Void) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        completion(center)
//        guard let previousLocation = previousLocation else { return }
//        let center = getCenterLocation(for: mapView)
//        guard center.distance(from: previousLocation) > 50 else { return }
//        self.previousLocation = center
//
//        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
//            self.showUserLocation()
//        }
    }
    
    //Reset all previously made routes before starting mew one
     func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    //Defining the center of visible map area
     func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
     func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
