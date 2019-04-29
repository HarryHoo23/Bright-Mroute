//
//  AccessibleSpotsViewController.swift
//  Mroute
//
//  Created by zhongheng on 4/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//
// This class is about the accessible Spots view controller, the accessible controller.


import UIKit
import MapKit
import Firebase

class AccessibleSpotsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var acMap: MKMapView!
 
    var imageArray = ["Information Center" ,
                      "Toilet",
                      "Park",
                      "Office",
                      "Parking Lot"]
                    // the arrayList of image, stored including the facility's names.
    var locationManager: CLLocationManager = CLLocationManager()
    var facility = [Facility]()
    let regionRadius: CLLocationDistance = 800

    override func viewDidLoad() {
        super.viewDidLoad()
        print(facility.count)
        self.collectionView.delegate = self // state the delegate of collection view in order to show pictures.
        self.collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(displayP3Red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        // set the collection view cell background color. 
        
        let initialLocation = CLLocation(latitude: -37.814, longitude: 144.96332)
        
        self.acMap.delegate = self // state the mapview delegate.
        acMap.isZoomEnabled = true
        acMap.isScrollEnabled = true
        locationManager.delegate = self
        addDifferentAnnotation(assetType: "Information Facilities") // show the initial annotations when user first time loaded the map.
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.acMap.showsUserLocation = true
            self.acMap.userLocation.title = "Your Current Location"
            centerViewOnUserLocation()
        }else{
            centerMapOnLocation(location: initialLocation)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        acMap.setRegion(coordinateRegion, animated: true)
    }
    
    // remove all annotations.
    func removeAnnotation(){
        self.acMap.removeAnnotations(self.acMap.annotations)
    }
    
    // add annotaions from facility array. 
    func addAnnotation(){
        for data in facility {
            let latitude = data.latitude!
            let longitude = data.longitude!
            let name = data.name!
            let type = data.assetType!
            let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
            let toiletsAnnotation = Annotation(newTitle: name, subtitle: type, location: fenceAnnotation)
            self.acMap.addAnnotation(toiletsAnnotation as MKAnnotation) // put annotations on map
            self.acMap.delegate = self
        }
    }
    
    func addDifferentAnnotation(assetType: String){
        for data in facility {
            if data.assetType == assetType {
                let latitude = data.latitude!
                let longitude = data.longitude!
                let name = data.name!
                let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
                let toiletsAnnotation = Annotation(newTitle: name, subtitle: assetType, location: fenceAnnotation)
                self.acMap.addAnnotation(toiletsAnnotation as MKAnnotation)
                self.acMap.delegate = self
            }
        }
    }
    
    // show the map as user on the center of the map. 
    func centerViewOnUserLocation(){
        let regionMeters: Double = 600 // circle range
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            acMap.setRegion(region, animated: true)
        }
    }

    // custom the annotation image, view. 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "fenceAnnotation")
        //let anno = annotation as! Annotation
        let resizedSize = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(resizedSize)
        
        // switch case by annotation's asset type name. 
        switch annotation.subtitle {
        case "Information Facilities":
            annotationView.image = UIImage(named: "green")
        case "Community Facilities":
            annotationView.image = UIImage(named: "sport")
        case "Park Facilities":
            annotationView.image = UIImage(named: "parkingLot")
        case "Leased Facilities":
            annotationView.image = UIImage(named: "hook")
        default:
            annotationView.image = UIImage(named: "zone")
        }
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: 40, height: 40)))
        mapsButton.setBackgroundImage(UIImage(named: "mapkit"), for: UIControl.State())
        annotationView.rightCalloutAccessoryView = mapsButton
        // allow user to tap the annotations
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
        // after tap the annotation can jump to the map to launch navigation.
    }

 
}

extension AccessibleSpotsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    // required code for collectionView.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    // define cells of the collectionView.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.acImage.image = UIImage(named: imageArray[indexPath.row]) // the name of each picture from array.
       
        cell.acImage.clipsToBounds = true // set the picture to round circle.
        cell.acImage.layer.borderColor = UIColor(displayP3Red: 217/255, green: 129/255, blue: 117/255, alpha: 0.5).cgColor
        cell.acImage.layer.borderWidth = 3
        cell.acImage.layer.masksToBounds = true
        cell.acImage.layer.cornerRadius = cell.acImage.frame.size.width / 2
       
        cell.acLabel.text = imageArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let name = imageArray[indexPath.row]
        // show the labels name of facility type names.
        switch name {
        case "Information Center":
            removeAnnotation()
            addDifferentAnnotation(assetType: "Information Facilities")
        case "Toilet":
            removeAnnotation()
            addDifferentAnnotation(assetType: "Community Facilities")
        case "Park":
            removeAnnotation()
            addDifferentAnnotation(assetType: "Park Facilities")
        case "Office":
            removeAnnotation()
            addDifferentAnnotation(assetType: "Leased Facilities")
        default:
            break
        }
    
    }
}
