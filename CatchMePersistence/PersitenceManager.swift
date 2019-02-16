//
//  PersitenceManager.swift
//  CatchMePersistence
//
//  Created by Victor Capilla Developer on 15/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

// Class defined for Manage the persistence of data
public final class PersistenceManager {

    
    /// Update or create the items passed by parameters. Use generic to use this function in all models from persistence module
    ///
    /// - Parameters:
    ///   - items: items to save
    ///   - completionHandler: Escaping closure indicateing if any error happends.
    public class func addUpdate<T: Object>(_ items: [T], completionHandler: @escaping (Bool) -> Void) {
        do {
            
            let realm = try Realm()
            try realm.write {
                for item in items {
                    realm.add(item, update: true)
                }
            }
            completionHandler(false)
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            completionHandler(true)

        }
    }
    
    
    /// Increments the ID property of the object of type that we send
    ///
    /// - Parameter type: Model used for define the Generic
    /// - Returns: Integer with the id generated.
    public class func incrementID<T: Object>(_ type: T.Type) -> Int {
        let realm = try! Realm()
        return (realm.objects(T.self).max(ofProperty: "id") ?? 0) + 1
    }
    
    
    /// Function for add without update
    ///
    /// - Parameters:
    ///   - items: items to save
    ///   - completionHandler: Escaping closure indicateing if any error happends.
    public class func add<T: Object>(_ items: [T], completionHandler: @escaping (Bool) -> Void) {
        do {
            
            let realm = try Realm()
            try realm.write {
                for item in items {
                    realm.add(item)
                }
            }
            completionHandler(false)
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            completionHandler(true)
            
        }
    }
    
    
    /// Function to get the items of a type
    ///
    /// - Parameters:
    ///   - filter: If we need to make any filter with the data, we can send in String format
    ///   - type: Type of data that we want to fetch
    ///   - completionHandler: Escaping closure indicateing if any error happends and, if have items of the Type, send in the closure
    public class func listItems<T: Object>(_ filter: String? = nil, _ type: T.Type, completionHandler: @escaping (Bool, [T]?) -> Void) {
        do {
            let realm = try Realm()
            let fetchResult: Results<T>?
            if let filter = filter {
                fetchResult = realm.objects(T.self).filter(filter)
            } else {
                fetchResult = realm.objects(T.self)
            }
            
            if let result = fetchResult {
                    completionHandler(false, Array(result))
            } else {
                completionHandler(false, nil)
            }
            
            
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            completionHandler(true, nil)
            
        }
    }
    
}
