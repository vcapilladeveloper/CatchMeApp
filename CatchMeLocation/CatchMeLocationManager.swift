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

// Extension to set new name identifier for Notifications
extension Notification.Name {
    static let error = Notification.Name("error")
}

// Protocol that define the actions to send to the delegate
public protocol CatchMeLocationDelegate {
    func updatePosition(_ location: CLLocation)
}

// Class that implement the Location Manager
final public class CatchMeLocationManager: CLLocationManager {
    
    // Reference to the Location Manager Delegate
    public var locationManagerDelegate: CatchMeLocationDelegate? = nil
    
    // Reference id to the actual journey to save the correspondent locations in JourneyLocation
    private var idActualJourney: Int?
    
    public override init() {
        super.init()
        // Ask for authorization
        requestAlwaysAuthorization()
        delegate = self
        startLocating()
    }
    
    
    // When start Locating, we need to save the information in one Journey. This function creates or fetch this Journey
    // Using PersistentManager.
    func getActualJourneyOrCreate() {
        // Get the Journey that hwe EndJourney state is false. If some error happends, send notification to show
        // Alert View with error message
        PersistenceManager.listItems("endJourney = false", Journey.self) { (error, data) in
            if !error {
                if let journey = data?.first {
                    self.idActualJourney = journey.id
                } else {
                    let actualJourney = Journey()
                    actualJourney.id = PersistenceManager.incrementID(Journey.self)
                    actualJourney.startDate = Date()
                    actualJourney.endJourney = false
                    PersistenceManager.addUpdate([actualJourney], completionHandler: { (error) in
                        if error {
                            NotificationCenter.default.post(name: .error, object: ["message": "Can't not create a new Journey"])
                        } else {
                            self.idActualJourney = actualJourney.id
                        }
                    })
                }
            } else {
                NotificationCenter.default.post(name: .error, object: ["message": "Can't fetch what you are waiting for"])
            }
        }
    }
    
    // Function for end registering in persistent data the actual Journey
    func stopActualJourney() {
        PersistenceManager.listItems("endJourney = false AND id = \(idActualJourney ?? 0)", Journey.self) { (error, data) in
            if !error {
                if let journey = data?.first {
                    journey.setEndJourney({ (error) in
                        if error {
                         NotificationCenter.default.post(name: .error, object: ["message": "Can't set end of Journey"])
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
    
    // Make action on startLocating
    public func startLocating() {
        startUpdatingLocation()
        startMonitoringSignificantLocationChanges()
        allowsBackgroundLocationUpdates = true
        getActualJourneyOrCreate()
    }
    
    
    // Make action on stop locatin
    public func stopLocating() {
        stopMonitoringSignificantLocationChanges()
        stopUpdatingLocation()
        allowsBackgroundLocationUpdates = false
        stopActualJourney()
    }
    
}

// Like CLLocationManagerDelegate we need to get the updated location when change. This happends in the Delegate functions
extension CatchMeLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if let id = idActualJourney {
                let journayLocation = JourneyLocation()
                journayLocation.journeyId = id
                journayLocation.latitude = location.coordinate.latitude
                journayLocation.longitude = location.coordinate.longitude
                PersistenceManager.add( [journayLocation], completionHandler: { (error) in
                    if error {
                        NotificationCenter.default.post(name: .error, object: ["message": "Can't not create a new JourneyLocation"])
                    }
                })
            }
           locationManagerDelegate?.updatePosition(location)
        }
    }
    
    
    /// In case error happends, show Alert View sending notification
    ///
    /// - Parameters:
    ///   - manager: The Location manager
    ///   - error: Error returned by the Location Service
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationCenter.default.post(name: .error, object: ["message": "Some problems for locate you..."])
    }
}
