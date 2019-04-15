//
//  DashBoardViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 30/3/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.

//  This is the class that when user load the application, initial page for user to navigate.

import UIKit
import Firebase // import firebase source code.
import MapKit

class DashBoardViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var ref: DatabaseReference! //reference of firebase database
    var handle: DatabaseHandle! // handle of the firebase database
    var finalFacility = [Facility]() // create the array of facility, saved as object.
    var prones = [ProneZone]() // create the array of pronezone, saved as object.
    var hookTurn = [HookTurn]() // create the array of hookturn, saved as object.
    
    
    @IBAction func roadAssistanceButton(_ sender: Any) {
        let phoneNumber = "1800105211"
        if let phoneURL = URL(string: "tel://\(phoneNumber)"){
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFacility()
        addProneZone()
        addHookTurn()
        // let addButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(tapButton))
        //self.navigationItem.rightBarButtonItem = addButton
        
        // let user to allow location authorization.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // add facility data into facility arraylist.
    func addFacility(){
        let ref2 = Database.database().reference().child("Facility")
        // retrieve data from firebase, the data source named "Facility"
        ref2.observe(.value , with: { snapshot in
            if snapshot.childrenCount > 0 || snapshot.childrenCount == 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot]{
                    let object = data.value as? [String: AnyObject]
                    let name = object?["Address"] as! String
                    let long = object?["Longitude"] as! Double
                    let lat = object?["Latitude"] as! Double
                    let type = object?["Asset Type"] as! String
                    let theFacility = Facility(name: name, type: type, longitude: long, latitude: lat)
                    // create a new object, saved all attributes as init.
                    self.finalFacility.append(theFacility)
                }
            }
        })
    }
    
    // similar to addFacility(), add hook turn data.
    func addHookTurn(){
        let ref2 = Database.database().reference().child("HookTurn")
        ref2.observe(.value , with: { snapshot in
            if snapshot.childrenCount > 0 || snapshot.childrenCount == 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot]{
                    let object = data.value as? [String: AnyObject]
                    let name = object?["Name_Of_Roads"] as! String
                    let long = object?["Lng"] as! Double
                    let lat = object?["Lat"] as! Double
                    let hookTurnInCBD = HookTurn(name: name, longitude: long, latitude: lat)
                    self.hookTurn.append(hookTurnInCBD)
                }
            }
        })
    }
    
    // similar to addFacility(), add pronezone data.
    func addProneZone(){
        let ref2 = Database.database().reference().child("ProneZone")
        ref2.observe(.value , with: { snapshot in
            if snapshot.childrenCount > 0 || snapshot.childrenCount == 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot]{
                    let object = data.value as? [String: AnyObject]
                    let name = object?["ROAD_GEOMETRY"] as! String
                    let long = object?["LONGITUDE"] as! Double
                    let lat = object?["LATITUDE"] as! Double
                    let speed = object?["SPEED_ZONE"] as! String
                    let prone1 = ProneZone(title: name, longtitude: long, latitude: lat, speed: speed)
                    self.prones.append(prone1)
                }
            }
        })
    }
    
    //pass data from dashborad to two different controllers.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MapViewController{
            let mc = segue.destination as? MapViewController
            mc?.proneZ = self.prones
            mc?.hookTurn = self.hookTurn
        }
        
        if segue.destination is AccessibleSpotsViewController{
            let ac = segue.destination as? AccessibleSpotsViewController
            ac?.facility = self.finalFacility
        }
    }
    
}
