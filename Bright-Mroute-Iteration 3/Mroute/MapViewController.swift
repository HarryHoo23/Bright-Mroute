//
//  MapViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 30/3/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.

//  This is class is about the prone zone and hook turn maps.

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var proneZ = [ProneZone]() // arraylist
    var hookTurn = [HookTurn]() // arraylist
    let regionRadius: CLLocationDistance = 2500
    
    //Global Variables
    var zoneName: String?
    var speedArea: String?
    var detail: String?
    var frequency: Int?
    var criticalLevel: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    
    @IBAction func currentLocationButton(_ sender: Any) {
        locationManager.startUpdatingLocation()
        
    }
    
    @IBOutlet weak var hookTurnAndProneZoneSegment: UISegmentedControl!
    // the segment control to let user switch between hook turn and prone zone
    
    @IBOutlet weak var zoneMap: MKMapView!
    
    @IBAction func filterType(_ sender: Any) {
        switch hookTurnAndProneZoneSegment.selectedSegmentIndex {
        case 0:
            removeAnnotation() //make sure it won't duplicate the annotations.
            addAnnotation()
        case 1:
            removeAnnotation()
            addHookTurnAnnotation()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Prone Map"
        let addButton = UIBarButtonItem(title: "Hybrid", style: .done, target: self, action: #selector(tapButton))
        // to change the map type
        let addButton1 = UIBarButtonItem(title: "Standard", style: .done, target: self, action: #selector(tapButton2))
        //change the map type when tap the button.
        self.navigationItem.rightBarButtonItems = [addButton, addButton1]
        
        let initialLocation = CLLocation(latitude: -37.814, longitude: 144.96332)
        self.zoneMap.delegate = self
        addAnnotation() // show the annotations when first loading the map.
        zoneMap.mapType = .standard
        zoneMap.isZoomEnabled = true
        zoneMap.isScrollEnabled = true
        
        // Do any additional setup after loading the view.
        if CLLocationManager.locationServicesEnabled(){
            self.zoneMap.showsUserLocation = true
            self.zoneMap.userLocation.title = "Your Current Location"
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            centerMapOnLocation(location: initialLocation)
        }else{
            print("error")
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func removeAnnotation(){
        self.zoneMap.removeAnnotations(self.zoneMap.annotations)
        // remove all annotations on the map.
    }
    
    func centerViewOnUserLocation(){
        // focus on the user's current location.
        let regionMeters: Double = 1000
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            zoneMap.setRegion(region, animated: true)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        zoneMap.setRegion(coordinateRegion, animated: true)
    }
    
    // the function to add prone zone annotation.
    func addAnnotation(){
        for data in proneZ {
            //read data from the prone zone arraylist
            let latitude = data.latitude!
            let longitude = data.longitude!
            let name = data.title!
            let speedZone = "Speed Zone: " + data.speedZone!
            let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
            let toiletsAnnotation = Annotation(newTitle: name, subtitle: speedZone, location: fenceAnnotation)
            self.zoneMap.addAnnotation(toiletsAnnotation as MKAnnotation)
        }
    }
    
    // the function to add hook turn annotation.
    func addHookTurnAnnotation(){
        for data in hookTurn {
            let latitude = data.latitude!
            let longitude = data.longitude!
            let name = data.name!
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            let hookAnnotation = Annotation(newTitle: name, subtitle: "Hook Turn", location: location)
            self.zoneMap.addAnnotation(hookAnnotation as MKAnnotation)
        }
    }
    
    // the function to focus on annotation
    func centerMapOnAnnotation(location: CLLocation) {
        let Radius: CLLocationDistance = 50
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: Radius, longitudinalMeters: Radius)
        zoneMap.setRegion(coordinateRegion, animated: true)
    }
    
    func focusOn(annotation: MKAnnotation) {
        self.zoneMap.centerCoordinate = annotation.coordinate
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.zoneMap.selectAnnotation(annotation, animated: true)
        centerMapOnAnnotation(location: location)
    }
    
    // change the image of the annotation on maps.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "fenceAnnotation")
        let resizedSize = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(resizedSize)
        
        // if statement to determine pin's images depends the types.
        if annotation.subtitle == "Hook Turn" {
            annotationView.image = UIImage(named: "hook")
        }else{
            annotationView.image = UIImage(named: "zone")
        }
        
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        let btn = UIButton(type: .infoLight)
        annotationView.rightCalloutAccessoryView = btn
        // allow user to tap the annotation.
        return annotationView
    }
    
    // store the annotation's information that user tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! MKAnnotation
        for data in proneZ{
            if data.latitude == annotation.coordinate.latitude && data.longitude == annotation.coordinate.longitude{
                frequency = data.frequency
                criticalLevel = data.criticalLevel
            }
        }
        let name = annotation.title
        let speedZone = annotation.subtitle
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        zoneName = name!
        speedArea = speedZone!
        locationLatitude = latitude
        locationLongitude = longitude
        self.performSegue(withIdentifier: "showDetailPage", sender: self)
    }
    
    // pass data from MapViewController to ZoneDetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetailPage"){
            let controller = segue.destination as! ZoneDetailViewController
            controller.name = zoneName
            controller.speedZone = speedArea
            controller.latitude = locationLatitude
            controller.longitude = locationLongitude
            controller.frequency = frequency
            controller.critical = criticalLevel
        }
    }
    
    // change the map type.
    @objc func tapButton(){
        self.zoneMap.mapType = .hybrid
    }
    
    @objc func tapButton2(){
        self.zoneMap.mapType = .standard
    }
    
}

extension MapViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Access the last object from locations to get perfect current location
        if let location = locations.last {
            let span = MKCoordinateSpan(latitudeDelta: 0.00775, longitudeDelta: 0.00775)
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region = MKCoordinateRegion(center: myLocation, span: span)
            zoneMap.setRegion(region, animated: true)
        }
        self.zoneMap.showsUserLocation = true
        manager.stopUpdatingLocation()
    }
}

