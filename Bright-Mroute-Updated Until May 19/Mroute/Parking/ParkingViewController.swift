//
//  ParkingViewController.swift
//  Mroute
//
//  Created by zhongheng on 4/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//  This is the class that let user save their parking location.

import UIKit
import MapKit
import CoreData

protocol newLocationDelegate {
    func didSaveLocation(_ annotation: Annotation)
}

class ParkingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var parkingMap: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pinImage: UIImageView!
    @IBAction func informationButtion(_ sender: Any) {
        displayMessage2("Move the map until the red pin is on the location you aim for, and click save location on the right top corner", "Save your Parking Location")
    } //Information button hit.
    
    var date: String?
    var newLatitude: Double?
    var newLongitude: Double?
    var longitude: String?
    var latitude: String?
    var parkingList = [Location]()
    var managedObjectContext: NSManagedObjectContext
    var delegate: newLocationDelegate?
    var currentLocation: CLLocationCoordinate2D?
    var locationManager: CLLocationManager = CLLocationManager()
    var previousLocation: CLLocation?
    
    // initialize the require code.
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder : aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parkingMap.delegate = self
        //Set the delegate of the apple map.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        pinImage.center = parkingMap.center
        let saveButton = UIBarButtonItem(title: "Save Location", style: .done, target: self, action: #selector(tapButton))
        self.navigationItem.rightBarButtonItem = saveButton
        //hard code to add a button on the right top corner.
        locationManager.delegate = self
        previousLocation = getCenterLocation(for: parkingMap)
        
        self.addressLabel.layer.borderWidth = 0.5
        self.addressLabel.layer.borderColor = UIColor.gray.cgColor
        
        //User's current Location.
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.parkingMap.showsUserLocation = true
            locationManager.startUpdatingLocation()
            centerViewOnUserLocation()
            self.parkingMap.userLocation.title = "Your Current Location"
        }else{
            locationManager.requestWhenInUseAuthorization()
        }
        parkingMap.mapType = .standard
        parkingMap.isZoomEnabled = true
        parkingMap.isScrollEnabled = true
        deleteAllData("Location")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
        sortByDate()
        self.tableView.reloadData()
    }
    
    //the Function to delete the data of parking location, if there is a bug in the application that cause it not run. Just run this function.
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                managedObjectContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    func saveData(){
        do {
            try managedObjectContext.save()
            // Save the core data, the parking location.
        }catch {
            displayMessage("Cannot be added!")
        }
    }
    
    //The function to retrive all parking location.
    func fetch(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        do{
            parkingList = try managedObjectContext.fetch(fetchRequest) as! [Location]
        }catch{
            print("Error")
        }
    }
    
    // Automatically update the parking list table.
    func insertRows(){
        fetch()
        let indexPath = IndexPath(row: parkingList.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    // Center on the user current location.
    func centerViewOnUserLocation(){
        let regionMeters: Double = 600
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            parkingMap.setRegion(region, animated: true)
        }
    }
    
    // Sort the parking location list by the data, shows the latest time parking location on the most top.
    func sortByDate(){
        parkingList = parkingList.sorted {$0.date! > $1.date! }
        self.tableView.reloadSections([0], with: .automatic)
    }
    
    //The function to add location, save into phone local data.
    func addLocation(){
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location
        latitude = "\(parkingMap.centerCoordinate.latitude)"
        longitude = "\(parkingMap.centerCoordinate.longitude)"
        newLocation.setValue("\(parkingMap.centerCoordinate.latitude)", forKey: "latitude")
        newLocation.setValue("\(parkingMap.centerCoordinate.longitude)", forKey: "longitude")
        // Read the current time from system.
        let currentDate = Date()
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let showDate = inputFormatter.string(from: currentDate)
        newLocation.setValue(showDate, forKey: "date")
        saveData()
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Table List.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return parkingList.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    // This function is about delete the parking location and alert to confirm the deletion.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 0{
            // Delete the row from the data source
            let alertController = UIAlertController(title: "Confirm To Delete", message: "Please Confirm Whether to Delete the Parking Location Or Not", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "Confirm", style: .destructive){(action) in
                let parkDelete = self.parkingList[indexPath.row]
                self.parkingList.remove(at: indexPath.row)
                self.managedObjectContext.delete(parkDelete)
                self.tableView.reloadData()
            }
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default){(action) in
                return
            }
            alertController.addAction(okAction)
            alertController.addAction(dismissAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // This function indicate the list of the parking location.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            var address : String?
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseLocation", for: indexPath)
            self.tableView.rowHeight = 80
            let m : Location
            m = self.parkingList[indexPath.row]
            if m.latitude != nil && m.longitude != nil {
                let newLatitude = Double(m.latitude!)
                let newLongitude = Double(m.longitude!)
                let location = CLLocation(latitude: newLatitude!, longitude: newLongitude!)
                self.locationManager.stopUpdatingLocation()
                // Convert the coordinate to real Address
                CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                    if error != nil{
                        print(error!.localizedDescription)
                    }else if placemarks != nil && (placemarks?.count)! > 0 {
                        // source of code to convert to the address.
                        let placemark = placemarks![0]
                        let addressname = placemark.name
                        let region = placemark.administrativeArea
                        let postcode = placemark.postalCode
                        let country = placemark.country
                        let street = placemark.locality
                        if addressname != nil && region != nil && postcode != nil && street != nil {
                            address = addressname! + ", " + street! + ", " + region! + " " + postcode! + ", " + country!
                        } else {
                            address = "Cannot read your address"
                        }
                        cell.detailTextLabel?.text = address
                    }
                }
            } else {
                print("Error")
            }
            cell.textLabel?.text = "\(indexPath.row + 1). Time: " + m.date!
            cell.accessoryType = .disclosureIndicator
            // Allow user to tap the cell.
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalParkingNumber", for: indexPath)
            cell.textLabel!.text = "Total Parking Number: " + "\(parkingList.count)"
            return cell
        }
    }
    
    // Pass the data from this controller to the detail controller.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.allowsSelection = true
        let m : Location
        if indexPath.section == 0 {
            m = self.parkingList[indexPath.row]
            newLongitude = Double(m.longitude!)
            newLatitude = Double(m.latitude!)
            date = m.date
            self.performSegue(withIdentifier: "showParking", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showParking")
        {
            let controller = segue.destination as! ParkingDetailViewController
            controller.latitude = newLatitude
            controller.longitude = newLongitude
            controller.date = date
        }
    }
    
    // The function to display the alert when user want to delete the parking locaiton.
    func displayMessage(_ message: String) {
        let alertController = UIAlertController(title: title, message: "Please Confirm Whether to Delete the Parking Location Or Not", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(okAction)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // The pin in the middle of the map, get the location of coordinate.
    func getCenterLocation(for parkingMap: MKMapView) -> CLLocation {
        let latitude = parkingMap.centerCoordinate.latitude
        let longitude = parkingMap.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    //Functions when user tap the save button.
    @objc func tapButton(){
        addLocation()
        insertRows()
        sortByDate()
        let alert = UIAlertController(title: "Successful", message: "Location Saved!", preferredStyle: UIAlertController.Style.alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.tableView.reloadData()
        }
        alert.addAction(dismissAction)
        self.present(alert,animated: true, completion: nil)
    }
}

//Extra code.
extension ParkingViewController{
    
    // The function to is to locate the center of the map's location, when user move the pin to locate their wanted location.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center  = getCenterLocation(for: parkingMap)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        guard center.distance(from: previousLocation) > 10 else {return}
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else {return}
            
            if let _ = error{
                return
            }
            
            guard let placemark = placemarks?.first else{
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let surburb = placemark.subLocality ?? ""
            //Show the address in the map.
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName), \(surburb)"
            }
            
        }
    }
    
    func displayMessage2(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
