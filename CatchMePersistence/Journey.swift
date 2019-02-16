//
//  Journey.swift
//  CatchMePersistence
//
//  Created by Victor Capilla Developer on 15/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

public class Journey: Object {
    @objc public dynamic var id = 0
    @objc public dynamic var startDate: Date = Date()
    @objc public dynamic var endDate: Date = Date()
    @objc public dynamic var endJourney: Bool = false
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
}
