//
//  LocationManager.swift
//  LocationManager
//
//  Created by Victor Capilla Developer on 13/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationProtocol {
    func updateFromLocationWithPolyline(_ location: CLLocationCoordinate2D)
}

class LocationManager: CLLocationManager {
}
