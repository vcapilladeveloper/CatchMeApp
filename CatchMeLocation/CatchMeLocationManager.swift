//
//  CatchMeLocationManager.swift
//  CatchMeLocation
//
//  Created by Victor Capilla Developer on 16/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import CoreLocation
import CatchMePersistence

extension Notification.Name {
    static let error = Notification.Name("error")
}

public protocol CatchMeLocationDelegate {
    func updatePosition(_ location: CLLocation)
}

final public class CatchMeLocationManager: CLLocationManager {
    
    public var locationManagerDelegate: CatchMeLocationDelegate? = nil
    private var idActualJourney: Int?
    
    public override init() {
        super.init()
        requestAlwaysAuthorization()
        allowsBackgroundLocationUpdates = true
        delegate = self
        startUpdatingLocation()
        
        
    }
    
    func getActualJourneyOrCreate() {
        PersistenceManager.listItems("endJourney = false", Journey.self) { (error, data) in
            if !error {
                if let journey = data?.first {
                    self.idActualJourney = journey.id
                } else {
                    let actualJourney = Journey()
                    actualJourney.startDate = Date()
                    actualJourney.endJourney = false
                    PersistenceManager.addUpdate([actualJourney], completionHandler: { (error) in
                        if error {
                            NotificationCenter.default.post(name: .error, object: ["message": "Can't not create a new Journey"])
                        }
                    })
                }
            } else {
                NotificationCenter.default.post(name: .error, object: ["message": "Can't fetch what you are waiting for"])
            }
        }
    }
    
    func stopActualJourney() {
        PersistenceManager.listItems("endJourney = false AND id = \(String(describing: idActualJourney))", Journey.self) { (error, data) in
            if !error {
                if let journey = data?.first {
                    journey.endDate = Date()
                    journey.endJourney = true
                    PersistenceManager.addUpdate([journey], completionHandler: { (error) in
                        if error {
                            NotificationCenter.default.post(name: .error, object: ["message": "Can't save the Journey"])
                        }
                    })
                } else {
                    NotificationCenter.default.post(name: .error, object: ["message": "Can't not fetch what you are waiting for"])
                }
            } else {
                NotificationCenter.default.post(name: .error, object: ["message": "Can't not fetch what you are waiting for"])
            }
        }
    }
    
    public func startLocating() {
        startUpdatingLocation()
        startMonitoringSignificantLocationChanges()
        getActualJourneyOrCreate()
    }
    
    public 	func stopLocating() {
        stopMonitoringSignificantLocationChanges()
        stopUpdatingLocation()
        stopActualJourney()
    }
    
}

extension CatchMeLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if let id = idActualJourney {
                let journayLocation = JourneyLocation()
                journayLocation.journeyId = id
                journayLocation.latitude = location.coordinate.latitude
                journayLocation.longitude = location.coordinate.longitude
                PersistenceManager.addUpdate( [journayLocation], completionHandler: { (error) in
                    if error {
                        NotificationCenter.default.post(name: .error, object: ["message": "Can't not create a new JourneyLocation"])
                    }
                })
            }
           locationManagerDelegate?.updatePosition(location)
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationCenter.default.post(name: .error, object: ["message": "Some problems for locate you..."])
    }
}
