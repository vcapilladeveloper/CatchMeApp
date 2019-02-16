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

public final class PersistenceManager {

    public class func addUpdate<T: Object>(items: [T], completionHandler: @escaping (Bool) -> Void) {
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
    
    public class func listItems<T: Object>(_ filter: String? = nil, completionHandler: @escaping (Bool, [T]?) -> Void) {
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
