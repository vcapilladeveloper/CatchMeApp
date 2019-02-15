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

class Journey: Object {
    @objc dynamic var id = 0
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var endDate: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
