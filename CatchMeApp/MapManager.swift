//
//  MapManager.swift
//  CatchMeApp
//
//  Created by Victor Capilla Developer on 16/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CatchMeLocation
import CatchMePersistence

final class MapManager: NSObject {

    // Reference of map to manage
    let mapView: MKMapView!
    
    // Locations to calculate locations route
    var locations: [JourneyLocation]?

    // Manager constructor
    required init(_ mapView: MKMapView) {
        self.mapView = mapView
        super.init()
    }
    
    
    /// Ask to the Persistence module the Journey route to locate in the map
    ///
    /// - Parameter journeyId: If we want to show the locations from concrete Journey, we can send the id of this Journey.
    func getLocationsToShow(_ journeyId: Int? = nil) {
        var filter: String? = nil
        if journeyId != nil { filter = "journeyId = \(journeyId!)" }
        PersistenceManager.listItems(filter, JourneyLocation.self) { (error, data) in
            if !error {
                if let locations = data {
                    self.setLocations(locations)
                } else {
                    NotificationCenter.default.post(name: .error, object: ["message": "Incorrect data format"])
                }
            } else {
                NotificationCenter.default.post(name: .error, object: ["message": "Can't not fetch what you are waiting for"])
            }
        }
    }
    
    
    /// Save the reference of locations fetched in getLocationsToShow
    ///
    /// - Parameter locations: Locations fetched
    func setLocations(_ locations: [JourneyLocation]) {
            self.locations = locations
    }
    
    
    /// Function to generate the Polyline for show in the map
    ///
    /// - Returns: Return the path to show in Polyline form to draw in the map
    private func polyLine() -> MKPolyline {
        getLocationsToShow()
        guard let locations = locations else {
            return MKPolyline()
        }

        let coords: [CLLocationCoordinate2D] = locations.map { location in
            let location = location
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
    
}

// Map delegate functions for update the map
extension MapManager: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
    }
    
}

// Location delegate function for send the updated position from the Location Manager.
extension MapManager: CatchMeLocationDelegate {
    
    func updatePosition(_ location: CLLocation) {
        
        let coordinate = location.coordinate
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        self.mapView.addOverlay(polyLine())
        
    }
}
