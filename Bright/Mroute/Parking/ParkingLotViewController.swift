//
//  ParkingLotViewController.swift
//  Mroute
//
//  Created by zhongheng on 27/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//  This class is responsible for the viewController that shows different parking lot.

import UIKit
import MapKit

struct ParkingBay: Decodable{ // Create a structure of the data in order to be stored.
    let bay_id: String
    let lon: String
    let lat: String
    let st_marker_id: String
    let status: String
    
    init(bay: String, longitude: String, latitude: String, marker: String, status: String){
        bay_id = bay
        lon = longitude
        lat = latitude
        st_marker_id = marker
        self.status = status
    }
}

class ParkingLotViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var parkingCollectionView: UICollectionView!
    @IBOutlet weak var parkingLotMap: MKMapView!
    
    var smart = [ParkingLot]()
    var p = [ParkingBay]()
    
    var parking = [ParkingLot]()
    var markers = [String]()
    var imageArray = ["less30",
                      "1PSign",
                      "2PSign",
                      "3PSign",
                      "4PSign",
                      "AllDay"]
    // the arraylist of image name, so that can show different image by retrieve from the array.
    var selectedAnnotation: MKAnnotation?
    var status: String?
    var duration: String?
    var time: String?
    var marker: String?
    var bayId: Int64?
    var days: String?
    var timeDuration: Int?
    var locationManager: CLLocationManager = CLLocationManager()
    
    var realParkingBay = [ParkingBay]()
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
        //Keep tracking user's current location when press button.
    }
    
    let regionRadius: CLLocationDistance = 2500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialLocation = CLLocation(latitude: -37.814, longitude: 144.96332)
        retrieveData()
        self.parkingLotMap.delegate = self
        addAnnotation()
        parkingLotMap.isZoomEnabled = true
        parkingLotMap.isScrollEnabled = true
        //needed source code
        self.parkingCollectionView.delegate = self
        // state the delegate of collection view in order to show pictures.
        self.parkingCollectionView.dataSource = self
        parkingCollectionView.backgroundColor = UIColor(displayP3Red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        // set the collection view cell background color.
    
        if CLLocationManager.locationServicesEnabled(){
            self.parkingLotMap.showsUserLocation = true
            self.parkingLotMap.userLocation.title = "Your Current Location"
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //locationManager.startUpdatingLocation()
            centerMapOnLocation(location: initialLocation)
        }else{
            print("error")
        }
        
        for data in parking {
            self.markers.append("\(data.bayId!)")
        }
        
        let button = UIBarButtonItem(title: "Show All", style: .done, target: self, action: #selector(showAll))
        self.navigationItem.rightBarButtonItem = button
        //retrieveData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveData()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        parkingLotMap.setRegion(coordinateRegion, animated: true)
    }
    
    func centerViewOnUserLocation(){
        // focus on the user's current location.
        let regionMeters: Double = 1000
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            parkingLotMap.setRegion(region, animated: true)
        }
    }
    
    func addAnnotation(){ // add all annotation on map.
        for index in 0..<smart.count{
            let latitude = smart[index].latitude!
            let longitude = smart[index].longitude!
            let status = p[index].status
            let type = smart[index].parkingDuration!
            let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
            let toiletsAnnotation = Annotation(newTitle: status, subtitle: "Parking Duration: " + type, location: fenceAnnotation)
            self.parkingLotMap.addAnnotation(toiletsAnnotation as MKAnnotation)
        }
    }
    
    func addDifferentAnnotation(parkingDuration: Int){
        //This function allow to show different annotation by filter. Based on the parking duration such as 2P, 4P.
        for index in 0..<smart.count{
            if smart[index].timeDuration! == parkingDuration{
                let latitude = smart[index].latitude!
                let longitude = smart[index].longitude!
                let status = p[index].status
                let type = smart[index].parkingDuration!
                let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
                let toiletsAnnotation = Annotation(newTitle: status, subtitle: "Parking Duration: " + type, location: fenceAnnotation)
                self.parkingLotMap.addAnnotation(toiletsAnnotation as MKAnnotation)
            }
        }

    }

    func removeAnnotation(){
        self.parkingLotMap.removeAnnotations(self.parkingLotMap.annotations)
    }
    
    @objc func showAll(){
        // the "Show all" button can show all the annotation on map.
        removeAnnotation()
        addAnnotation()
    }
    
    func retrieveData(){
        var smartParking = [ParkingBay]()
 
        let url = "https://data.melbourne.vic.gov.au/resource/vh2v-4nfs.json?$select=bay_id,%20lat,%20lon,status,st_marker_id"
        guard let jsonUrl = URL(string: url) else {return}
        
        URLSession.shared.dataTask(with: jsonUrl) {(data, response, error) in
            
            guard let data = data else{return}
            //let dataAsString = String(data: data, encoding: .utf8)
            //print(dataAsString!)
            do {
                let parkingBay = try JSONDecoder().decode([ParkingBay].self, from: data)
                for data in parkingBay {
                    let bayid = data.bay_id
                    let lon = data.lon
                    let lat = data.lat
                    let status = data.status
                    let marker = data.st_marker_id
                    let theParkingBay = ParkingBay(bay: bayid, longitude: lon, latitude: lat, marker: marker, status: status)
                    smartParking.append(theParkingBay)
                    let bay = Int64(bayid)
                    let parking = self.parking.filter{$0.bayId == bay}
                    self.smart.append(contentsOf: parking)
                    self.smart = self.smart.sorted {$0.bayId! < $1.bayId!}
                }
                

                for i in self.markers{
                    let smartParkings = smartParking.filter{$0.bay_id == i}
                    self.p.append(contentsOf: smartParkings)
                    self.p = self.p.sorted {$0.bay_id < $1.bay_id}
                }

            }catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}


extension ParkingLotViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    //define the cells of collectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = parkingCollectionView.dequeueReusableCell(withReuseIdentifier: "parkingLotCell", for: indexPath) as! ParkingCollectionViewCell
        cell.parkingLotImage.image = UIImage(named: imageArray[indexPath.row]) // the name of each picture from array.
        cell.parkingLotImage.clipsToBounds = true
        cell.parkingLotImage.layer.borderColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        cell.parkingLotImage.layer.borderWidth = 3
        cell.parkingLotImage.layer.masksToBounds = true
        cell.parkingLotImage.layer.cornerRadius = cell.parkingLotImage.frame.size.width / 2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // this function allow us to click on the images to filter the annotation.
        let name = imageArray[indexPath.row]
        switch name {
            //this is based on the parking duration to show all the annotation, taking from parking time.
        case "less30":
            removeAnnotation()
            addDifferentAnnotation(parkingDuration: 5)
            addDifferentAnnotation(parkingDuration: 10)
            addDifferentAnnotation(parkingDuration: 15)
            addDifferentAnnotation(parkingDuration: 30)
        case "1PSign":
            removeAnnotation()
            addDifferentAnnotation(parkingDuration: 60)
        case "2PSign":
            removeAnnotation()
            addDifferentAnnotation(parkingDuration: 120)
        case "3PSign":
            removeAnnotation()
            addDifferentAnnotation(parkingDuration: 180)
        case "4PSign":
            removeAnnotation()
            addDifferentAnnotation(parkingDuration: 240)
        case "AllDay":
            removeAnnotation()
            addDifferentAnnotation(parkingDuration: 1440)
        default: break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        let resizedSize = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(resizedSize)
        
        // if statement to determine pin's images depends on the status.
        if annotation.title == "Unoccupied" {
            annotationView.image = UIImage(named: "greenpin")
        }else{
            annotationView.image = UIImage(named: "pin")
        }
        
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        
        let btn = UIButton(type: .infoLight)
        annotationView.rightCalloutAccessoryView = btn
        //btn.addTarget(self, action: #selector(pressButton), for: .touchDown)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! MKAnnotation
        for index in 0..<smart.count {
            if smart[index].latitude == annotation.coordinate.latitude && smart[index].longitude == annotation.coordinate.longitude{
                status = p[index].status
                duration = smart[index].parkingDuration
                time = smart[index].time
                bayId = smart[index].bayId
                timeDuration = smart[index].timeDuration
                days = smart[index].days
                marker = smart[index].streetMarkerId
                //print(status!)
            }
        selectedAnnotation = annotation
        
            // allow user to tap the annotation.
        }
        self.performSegue(withIdentifier: "showPopUp", sender: self)// show the pop up view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Pass all the data to the pop up view.
        if (segue.identifier == "showPopUp"){
            let popVc = segue.destination as! MapPopUpViewController
            popVc.status = status
            popVc.duration = duration
            popVc.time = time
            popVc.days = days
            popVc.bayId = bayId
            popVc.marker = marker
            popVc.annotation = selectedAnnotation
            popVc.timeDuration = timeDuration
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Access the last object from locations to get perfect current location
        if let location = locations.last {
            let span = MKCoordinateSpan(latitudeDelta: 0.00775, longitudeDelta: 0.00775)
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region = MKCoordinateRegion(center: myLocation, span: span)
            parkingLotMap.setRegion(region, animated: true)
        }
        self.parkingLotMap.showsUserLocation = true
        manager.stopUpdatingLocation()
    }
    
}
