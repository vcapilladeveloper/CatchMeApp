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

    let mapView: MKMapView!
    var locations: [JourneyLocation]?
    override init(_ mapView: MKMapView) {
        self.mapView = mapView
        super.init()
    }
    
    func getLocationsToShow(_ journeyId: Int? = nil) {
        var filter = nil
        if let id = journeyId { filter = "journeyId = \(journeyId)" }
        PersistenceManager.listItems(filter) { (error, data) in
            if !error {
                if let locations = data as? [JourneyLocation]{
                    setLocations(locations)
                } else {
                    NotificationCenter.default.post(name: "error", object: ["message": "Incorrect data format"])
                }
            } else {
                NotificationCenter.default.post(name: "error", object: ["message": "Can't not fetch what you are waiting for"])
            }
        }
    }
    
    func setLocations(_ locations: [JourneyLocation]) {
            self.locations = locations
    }
    
    private func polyLine() -> MKPolyline {
        getLocationsToShow()
        guard let locations = userLocations else {
            return MKPolyline()
        }

        let coords: [JourneyLocation] = locations.map { location in
            let location = location
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
    
}

extension MapManager: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
    }
    
}

extension MapManager: CatchMeLocationDelegate {
    
    func updatePosition(_ location: CLLocation) {
        
        let coordinate = location.coordinate
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        self.mapView.addOverlay(polyLine())
        
    }
}
