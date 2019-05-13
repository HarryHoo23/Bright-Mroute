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

struct provider {
    var name: String?
    var phoneNumber: String?
    
    init(providerName: String, phone: String) {
        name = providerName
        phoneNumber = phone
    }
}

class DashBoardViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var ref: DatabaseReference! //reference of firebase database
    var handle: DatabaseHandle! // handle of the firebase database
    var finalFacility = [Facility]() // create the array of facility, saved as object.
    var prones = [ProneZone]() // create the array of pronezone, saved as object.
    var hookTurn = [HookTurn]() // create the array of hookturn, saved as object.
    var quizArray = [Question]()
    var parking = [ParkingLot]()
    var roadAssistance = [provider]()
    var marker = [String]()
    var providerName: String?
    var phoneNumber: String?
    var longitude: Double?
    var latidude: Double?
    var degree: Int!
    var condition: String!
    var city : String!
    var imageUrl : String!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFacility()
        addProneZone()
        addHookTurn()
        addParkingLot()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        let image = UIImage(named: "phone")
        let location = locationManager.location
        longitude = location?.coordinate.longitude
        latidude = location?.coordinate.latitude
        self.ref = Database.database().reference().child("RoadAssistance")
        let yellowColor = UIColor(red: 255/255, green: 255/255, blue: 126/255, alpha: 1)
        let orangeColor = UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)
        let lightOrangeColor = UIColor(red: 252/255, green: 214/255, blue: 112/255, alpha: 1)
        view.setGradientBackgroundColor(colorOne: lightOrangeColor, colorTwo: yellowColor)
        weatherView.backgroundColor = orangeColor
        weatherView.layer.cornerRadius = 20
        let phoneButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(tapButton))
        self.navigationItem.rightBarButtonItem = phoneButton
        getWeather()
        addUserName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addQuestion()
        saveRoadAssistance()
        //let userID = Auth.auth().currentUser!.uid

    }
    
    func addUserName(){
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("Users").child(uid!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let name = dictionary["firstName"] as? String
                self.welcomeLabel.text = "Welcome " + name! + "!"
            }
        })
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
  
    @objc func tapButton(){
        if let phoneURL = URL(string: "tel://\(self.phoneNumber!)"){
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
}

extension DashBoardViewController {
    
    func saveRoadAssistance(){
        self.ref.observe(.value, with: { (snapshot) in
            for data in snapshot.children.allObjects as! [DataSnapshot]{
                let object = data.value as? [String : AnyObject]
                let name = object?["Company"] as! String
                let phone = object?["Phone"] as! String
                let assistance = provider(providerName: name, phone: phone)
                self.roadAssistance.append(assistance)
            }
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("Users").child(uid!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.providerName = dictionary["roadAssistance"] as? String
                    for data in self.roadAssistance {
                        if self.providerName! == data.name {
                            self.phoneNumber = data.phoneNumber
                        }
                    }
                }
            })
        })
    }
    
    func getWeather(){
        let url = "http://api.apixu.com/v1/current.json?key=b7d3f33abecc4920a1d43056191005&q=" + "\(latidude!)," + "\(longitude!)"
        guard let jsonUrl = URL(string: url) else {return}
        URLSession.shared.dataTask(with: jsonUrl) {(data, response, error) in
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    if let current = json["current"] as? [String : AnyObject]{
                        if let temp = current["temp_c"] as? Int {
                            self.degree = temp
                        }
                        if let condition = current["condition"] as? [String : AnyObject] {
                            let currentCondition = condition["text"] as! String
                            self.condition = currentCondition
                            let icon = condition["icon"] as! String
                            self.imageUrl = "http:\(icon)"
                        }
                        if let location = json["location"] as? [String : AnyObject] {
                            self.city = location["name"] as! String
                        }
                        DispatchQueue.main.async {
                            self.temperatureLabel.text = "\(self.degree!) °C"
                            self.cityLabel.text = self.city!
                            self.conditionLabel.text = self.condition!
                            self.weatherImageView.download(from: self.imageUrl!)
                        }
                    }
                    
                }catch {
                    print(error.localizedDescription)
                }
            }
            
            
        }.resume()
    }
}

extension UIImageView {
    func download(from url : String){
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.image = UIImage (data: data!)
                }
            }
        }
        task.resume()
    }
}
