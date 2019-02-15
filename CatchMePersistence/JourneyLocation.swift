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

class JourneyLocation: Object {
    @objc dynamic var journeyId = 0
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
}
