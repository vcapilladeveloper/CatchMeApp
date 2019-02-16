//
//  JourneyLocation.swift
//  CatchMePersistence
//
//  Created by Victor Capilla Developer on 15/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

// Model to save each loction of a Journey
public class JourneyLocation: Object {
    @objc public dynamic var journeyId = 0 // Id for specify the related information Journey
    @objc public dynamic var latitude: Double = 0.0 // Latitude registered for a Journey
    @objc public dynamic var longitude: Double = 0.0 // Longitude registered for a Journey
}
