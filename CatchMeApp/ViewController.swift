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
import CatchMePersistence
import CatchMeTools

extension Notification.Name {
    static let error = Notification.Name("error")
}


/// Class for manage the UI with map and TableView loaded programmatically
final class ViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var trackingSwitchContainer: UIStackView!
    @IBOutlet weak var startEndLocationContainer: UIStackView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var trackingSwitchContainerBackground: UIView!
    
    @IBOutlet weak var endStartDateLabelsBackground: UIView!
    
    
    @IBOutlet weak var startDateTitle: UILabel!
    @IBOutlet weak var startDate: UILabel!
    
    @IBOutlet weak var endDateTitle: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    // This property is the collection to load in the TableView
    var journeysToShow: [Journey]?
    
    // Property to save a reference of the TableView list when we show
    var listOfJourney: UIView?
    
    // Journey selected from the TableView
    var selectedJourney: Journey?
    
    // Map manager to update the info in map and is the Delegate of LocationManager
    var mapManager: (MapManager & CatchMeLocationDelegate)?
    
    // Location Manager, for catch the location and start and stop updating location.
    var locationManager: CatchMeLocationManager? = nil
    
    
    /// Action to show or hide the list of Journey of the user.
    /// In case Journey View is actlually in the baseView, removeit and reset the view.
    ///
    /// - Parameter sender: Button tapped
    @IBAction func showList(_ sender: UIButton) {
        // In case reference of the List of Journey is set, it seams like it's necessary to hide. and
        // restart the state of this ViewController
        if listOfJourney != nil {
            listOfJourney = nil
            trackingSwitchContainer.isHidden = false
            startEndLocationContainer.isHidden = true
            endStartDateLabelsBackground.isHidden = true
            trackingSwitchContainerBackground.isHidden = false
            listButton.setTitle("Show My Journeys", for: .normal)
            locationManager?.startLocating()
            map.showsUserLocation = true
        } else {
            PersistenceManager.listItems(nil, Journey.self) { (error, journeys) in
                if !error {
                    if let listOfJourneys = journeys, listOfJourneys.count > 0 {
                        self.journeysToShow = listOfJourneys
                        let baseView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height))
                        self.listOfJourney = baseView
                        baseView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                        let tableView = UITableView(frame: CGRect(x: 20.0, y: 20.0, width: self.view.frame.width - 40.0, height: self.view.frame.height - 40.0))
                        tableView.layer.cornerRadius = 4.0
                        tableView.delegate = self
                        tableView.dataSource = self
                        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                        baseView.addSubview(tableView)
                        self.view.addSubview(baseView)
                        tableView.reloadData()
                        self.map.showsUserLocation = false
                    }
                }
            }
        }
    }
    
    
    /// Action to start or stop tracking the position of the user
    ///
    /// - Parameter sender: UISwitch
    @IBAction func onOffTracking(_ sender: UISwitch) {
        if sender.isOn {
            map.showsUserLocation = false
            locationManager?.stopLocating()
        } else {
            map.showsUserLocation = true
            locationManager?.startLocating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Action to add Observer to catch the notification in case is need to show an Alert Error.
        NotificationCenter.default.addObserver(self, selector: #selector(showSimpleAlert(_:)), name: .error, object: nil)
        
        // Set map, map manager and Location manager.
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        
        mapManager = MapManager(map)
        map.delegate = mapManager
        locationManager = CatchMeLocationManager()
        locationManager!.locationManagerDelegate = mapManager as! CatchMeLocationDelegate
        
        // Hide the labels of start and end dates
        startEndLocationContainer.isHidden = true
        endStartDateLabelsBackground.isHidden = true
    }
    
    
    /// Action to show the Alert when notification with error type is recived
    ///
    /// - Parameter notificaction: notificatin recived
    @objc func showSimpleAlert(_ notificaction: Notification) {
        
        var errorMessage = "Ups, something went wrong!"
        
        if let data = notificaction.object as? [String: String], let message = data["message"] {
            errorMessage = message
        }
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alert) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// Draw journey route in the map from table view selection
    ///
    /// - Parameter journey: Journey Selected
    func showJourneyInMap(_ journey: Journey) {
        // Stop locating the user location in the map
        locationManager?.stopLocating()
        
        // Save reference of Selected Journey from TableView
        selectedJourney = journey
        
        // Prepre view to show the Journey selected information in the view
        trackingSwitchContainer.isHidden = true
        startEndLocationContainer.isHidden = false
        endStartDateLabelsBackground.isHidden = false
        trackingSwitchContainerBackground.isHidden = true
        listButton.setTitle("Go Back", for: .normal)
        
        // Remove list from de view
        listOfJourney?.removeFromSuperview()
        
        // Set the StartDate and EndDate Text Label
        startDate.text = DateHelper.giveMeTodayDate((selectedJourney?.startDate)!)
        endDate.text = DateHelper.giveMeTodayDate((selectedJourney?.endDate)!)
        
        // Refresh map with the locations of the selected journey
        mapManager?.getLocationsToShow(journey.id)
    }
    
}

// TableView delegates and datasource for setup the information and get the cell selection
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let journey = journeysToShow?[indexPath.row]
        cell?.textLabel?.text = "Journey from: \(DateHelper.giveMeTodayDate((journey?.startDate)!))"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeysToShow?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let journey = journeysToShow?[indexPath.row] {
            showJourneyInMap(journey)
        }
        
    }
}
