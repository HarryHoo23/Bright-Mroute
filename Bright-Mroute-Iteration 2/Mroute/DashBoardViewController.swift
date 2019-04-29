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
    var quizArray = [Question]()
    var parking = [ParkingLot]()
    
//    @IBAction func roadAssistanceButton(_ sender: Any) {
//        let phoneNumber = "1800105211"
//        if let phoneURL = URL(string: "tel://\(phoneNumber)"){
//            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFacility()
        addProneZone()
        addHookTurn()
        addQuestion()
        addParkingLot()
        // let addButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(tapButton))
        //self.navigationItem.rightBarButtonItem = addButton
        
        // let user to allow location authorization.
        //self.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // add facility data into facility arraylist.
    func addFacility(){
        var newFacility = [Facility]()
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
                    newFacility.append(theFacility)
                }
            }
            self.finalFacility = newFacility
        })
    }
    
    // similar to addFacility(), add hook turn data.
    func addHookTurn(){
        var hook = [HookTurn]()
        let ref2 = Database.database().reference().child("HookTurn")
        ref2.observe(.value , with: { snapshot in
            if snapshot.childrenCount > 0 || snapshot.childrenCount == 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot]{
                    let object = data.value as? [String: AnyObject]
                    let name = object?["Name_Of_Roads"] as! String
                    let long = object?["Lng"] as! Double
                    let lat = object?["Lat"] as! Double
                    let hookTurnInCBD = HookTurn(name: name, longitude: long, latitude: lat)
                    hook.append(hookTurnInCBD)
                }
            }
            self.hookTurn = hook
        })
    }
    
    // similar to addFacility(), add pronezone data.
    func addProneZone(){
        var proneZone = [ProneZone]()
        let ref2 = Database.database().reference().child("ProneZone")
        ref2.observe(.value , with: { snapshot in
            if snapshot.childrenCount > 0 || snapshot.childrenCount == 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot]{
                    let object = data.value as? [String: AnyObject]
                    let name = object?["ROAD_GEOMETRY"] as! String
                    let long = object?["LONGITUDE"] as! Double
                    let lat = object?["LATITUDE"] as! Double
                    let speed = object?["SPEED_ZONE"] as! String
                    let critical = object?["Critical Level"] as! String
                    let frequency = object?["Frequency"] as! Int
                    let prone1 = ProneZone(title: name, longtitude: long, latitude: lat, speed: speed, critical: critical, frequency: frequency)
                    proneZone.append(prone1)
                }
            }
            self.prones = proneZone
        })
    }
    
    func addQuestion(){
        var newQuiz = [Question]()
        var correctAnswer: Int = 0
        let ref2 = Database.database().reference().child("Quiz")
        ref2.observe(.value , with: { snapshot in
            if snapshot.childrenCount > 0 || snapshot.childrenCount == 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot]{
                    let object = data.value as? [String: AnyObject]
                    let question = object?["Question"] as! String
                    let choiceA = object?["Option A"] as! String
                    let choiceB = object?["Option B"] as! String
                    let choiceC = object?["Option C"] as! String
                    let choiceD = object?["Option D"] as! String
                    let answer = object?["Answer"] as! String
                    let number = object?["No"] as! Int
                    let description = object?["Description"] as! String
                    switch answer {
                    case "A" :
                        correctAnswer = 0
                    case "B":
                        correctAnswer = 1
                    case "C":
                        correctAnswer = 2
                    case "D":
                        correctAnswer = 3
                    default:
                        break
                    }
                    let quiz = Question(questionText: question, choiceA: "A. " + choiceA, choiceB: "B. " + choiceB, choiceC: "C. " + choiceC, choiceD: "D. " + choiceD, answer: correctAnswer, qNumber: number, qDescription: description)
                    newQuiz.append(quiz)
                }
            }
            self.quizArray = newQuiz
            //print(self.quizArray.count)
        })
    }
    //This function is going to add the parkinglot information
    func addParkingLot(){
        var parks = [ParkingLot]()
        let ref2 = Database.database().reference().child("ParkingLot")
        ref2.observe(.value , with: { snapshot in
            if snapshot.childrenCount > 0 || snapshot.childrenCount == 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot]{
                    let object = data.value as? [String: AnyObject]
                    let long = object?["lon"] as! Double
                    let lat = object?["lat"] as! Double
                    let bayId = object?["Bay_id"] as! Int64
                    let timeDuration = object?["TimeDuration"] as! Int
                    let parkingDuration = object?["Parking_Duration"] as! String
                    let payment = object?["Pay_Type"] as! String
                    let streetId = object?["st_marker_id"] as! String
                    let time = object?["Time"] as! String
                    let status = object?["status"] as! String
                    let days = object?["Days"] as! String
                    let parkingLot = ParkingLot(longitude: long, latitude: lat, bayID: bayId, timeduration: timeDuration, duration: parkingDuration, payType: payment, streetID: streetId, parkTime: time, status: status, days: days)
                    parks.append(parkingLot)
                }
            }
            self.parking = parks
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
        
        if segue.destination is RulesViewController{
            let rc = segue.destination as? RulesViewController
            rc?.questions = self.quizArray
        }
        
        if segue.destination is ParkingLotViewController{
            let pc = segue.destination as? ParkingLotViewController
            pc?.parking = self.parking
        }
    }
    
}
