//
//  ViewController.swift
//  CatchMeApp
//
//  Created by Victor Capilla Developer on 13/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import UIKit
import MapKit
import CatchMeLocation

extension Notification.Name {
    static let error = Notification.Name("error")
}

class ViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    var locationManager: CatchMeLocationManager? = nil
    
    @IBAction func onOffTracking(_ sender: UISwitch) {
        if sender.isOn {
            map.showsUserLocation = false
            locationManager?.stopLocating()
        } else {
            map.showsUserLocation = true
            locationManager?.startLocating()
        }
        sender.isOn = !sender.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(showSimpleAlert(_:)), name: .error, object: nil)
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        
        let mapManager: (MapManager & CatchMeLocationDelegate) = MapManager(map)
        map.delegate = mapManager
        locationManager = CatchMeLocationManager()
        locationManager!.locationManagerDelegate = mapManager as CatchMeLocationDelegate
        
    }
    
    @objc func showSimpleAlert(_ notificaction: Notification) {
        
        var errorMessage = "Ups, something went wrong!"
        
        if let data = notificaction.userInfo as? [String: String], let message = data["message"] {
            errorMessage = message
        }
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "OK", style: .default, )
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alert) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
