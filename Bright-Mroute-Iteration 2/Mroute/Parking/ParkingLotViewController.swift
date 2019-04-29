//
//  ParkingLotViewController.swift
//  Mroute
//
//  Created by zhongheng on 27/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//  This class is responsible for the viewController that shows different parking lot.

import UIKit
import MapKit

class ParkingLotViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var parkingCollectionView: UICollectionView!
    @IBOutlet weak var parkingLotMap: MKMapView!
    var parking = [ParkingLot]()
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
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
        //Keep tracking user's current location when press button.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parkingLotMap.delegate = self
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
            locationManager.startUpdatingLocation()
            centerViewOnUserLocation()
        }else{
            print("error")
        }
        
        let button = UIBarButtonItem(title: "Show All", style: .done, target: self, action: #selector(showAll))
        self.navigationItem.rightBarButtonItem = button
        addAnnotation() // add all the parking bays.
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
        for data in parking {
            //read data from the prone zone arraylist
            let latitude = data.latitude!
            let longitude = data.longitude!
            let status = data.status! //Parking location status
            let type = data.parkingDuration!
            let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
            let parkingAnnotation = Annotation(newTitle: status, subtitle: "Parking Duration: " + type, location: fenceAnnotation)
            self.parkingLotMap.addAnnotation(parkingAnnotation as MKAnnotation)
        }
    }
    
    func addDifferentAnnotation(parkingDuration: Int){
        //This function allow to show different annotation by filter. Based on the parking duration such as 2P, 4P.
        for data in parking {
            if data.timeDuration! == parkingDuration {
                let latitude = data.latitude!
                let longitude = data.longitude!
                let status = data.status!
                let type = data.parkingDuration!
                let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
                let toiletsAnnotation = Annotation(newTitle: status, subtitle: "Parking Duration: " + type, location: fenceAnnotation)
                self.parkingLotMap.addAnnotation(toiletsAnnotation as MKAnnotation)
                self.parkingLotMap.delegate = self
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
        for data in parking {
            if data.latitude == annotation.coordinate.latitude && data.longitude == annotation.coordinate.longitude{
                status = data.status
                duration = data.parkingDuration
                time = data.time
                bayId = data.bayId
                timeDuration = data.timeDuration
                days = data.days
                marker = data.streetMarkerId
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
