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

// Model to save the Journey
public class Journey: Object {
    @objc public dynamic var id = 0 // Id of the journey
    @objc public dynamic var startDate: Date = Date() // Date when start to register the location of Journey
    @objc public dynamic var endDate: Date = Date() // Date when end registering the location of Journey
    @objc public dynamic var endJourney: Bool = false // State of the Journey registration
    
    // Specify the primary Key of the Realm Model
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    
    /// Set the end of a journey
    ///
    /// - Parameter completionHandler: Escaping closure to tell user if something wrong happends.
    public func setEndJourney(_ completionHandler: @escaping (_ error: Bool) -> Void) {
        do {
            
            let realm = try Realm()
            try realm.write {
                self.endDate = Date()
                self.endJourney = true
            }
            completionHandler(false)
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            completionHandler(true)
        }
    }
    
}
