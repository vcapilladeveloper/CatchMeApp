//
//  ViewController.swift
//  CatchMeApp
//
//  Created by Victor Capilla Developer on 13/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import UIKit
import MapKit
import CatchMeTools

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    @IBAction func onOffTracking(_ sender: UISwitch) {
        if sender.isOn {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.stopUpdatingLocation()
            map.showsUserLocation = false
            // TODO: Save Stop
            userLocations = []
        } else {
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            map.showsUserLocation = true
            // TODO: Save Start
            userLocations = []
        }
        sender.isOn = !sender.isOn
    }
    
    var locationManager: CLLocationManager!
    var userLocations: [UserLocation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Make a separate MapDelegate
        map.showsUserLocation = true
        map.delegate = self
        // TODO: Get last location saved if not stop traking.
        userLocations = []
        // TODO: Separate and make one Location Manager Delegate for interact with the map
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
    }
    
    
    // TODO: Move to Location Mamnager
    private func polyLine() -> MKPolyline {
        guard let locations = userLocations else {
            return MKPolyline()
        }
        
        let coords: [CLLocationCoordinate2D] = locations.map { location in
            let location = location
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
}

// TODO: Move to LocationManager
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let coordinate = location.coordinate
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            if userLocations != nil {
                userLocations?.append(UserLocation(idJourney: 1, latitude: coordinate.latitude, longitude: coordinate.longitude, date: Date()))
            } else {
                
                userLocations?.append(UserLocation(idJourney: 1, latitude: coordinate.latitude, longitude: coordinate.longitude, date: Date()))
            }
            print(userLocations?.count)
            self.map.setRegion(region, animated: true)
            self.map.addOverlay(polyLine())
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
    }
}
