//
//  AccessibleSpotsViewController.swift
//  Mroute
//
//  Created by zhongheng on 4/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class AccessibleSpotsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    // @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var acMap: MKMapView!
 
    /*
    @IBAction func changeMap(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            removeAnnotation()
            addDifferentAnnotation(assetType: "Information Facilities")
        case 1:
            removeAnnotation()
            addDifferentAnnotation(assetType: "Community Facilities")
        case 2:
            removeAnnotation()
            addDifferentAnnotation(assetType: "Park Facilities")
        default:
            break
        }
    }
 */
    
    var imageArray = ["Information Center" ,
                      "Toilet",
                      "Park",
                      "Office",
                      "Parking Lot"]
    
    var locationManager: CLLocationManager = CLLocationManager()
    var facility = [Facility]()
    let regionRadius: CLLocationDistance = 800
    var ref: DatabaseReference!
    var handle: DatabaseHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(facility.count)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(displayP3Red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        
        let initialLocation = CLLocation(latitude: -37.814, longitude: 144.96332)
        
        self.acMap.delegate = self
        acMap.isZoomEnabled = true
        acMap.isScrollEnabled = true
        locationManager.delegate = self
        addDifferentAnnotation(assetType: "Information Facilities")
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
    
    func removeAnnotation(){
        self.acMap.removeAnnotations(self.acMap.annotations)
    }
    
    func addAnnotation(){
        for data in facility {
            let latitude = data.latitude!
            let longitude = data.longitude!
            let name = data.name!
            let type = data.assetType!
            let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
            let toiletsAnnotation = Annotation(newTitle: name, subtitle: type, location: fenceAnnotation)
            self.acMap.addAnnotation(toiletsAnnotation as MKAnnotation)
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
    
    func centerViewOnUserLocation(){
        let regionMeters: Double = 600
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            acMap.setRegion(region, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "fenceAnnotation")
        //let anno = annotation as! Annotation
        let resizedSize = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(resizedSize)
        
        switch annotation.subtitle {
        case "Information Facilities":
            annotationView.image = UIImage(named: "green")
        case "Community Facilities":
            annotationView.image = UIImage(named: "sport")
        case "Park Facilities":
            annotationView.image = UIImage(named: "parkingLot")
        case "Leased Facilities":
            annotationView.image = UIImage(named: "hook")
        /*
        case "Sport Facilities":
            annotationView.image = UIImage(named: "hook")
        case "Park Facilities":
            annotationView.image = UIImage(named: "hook")*/
        default:
            annotationView.image = UIImage(named: "zone")
        }
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: 40, height: 40)))
        mapsButton.setBackgroundImage(UIImage(named: "mapkit"), for: UIControl.State())
        annotationView.rightCalloutAccessoryView = mapsButton
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AccessibleSpotsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.acImage.image = UIImage(named: imageArray[indexPath.row])
        
        cell.acImage.clipsToBounds = true
        cell.acImage.layer.borderColor = UIColor(displayP3Red: 217/255, green: 129/255, blue: 117/255, alpha: 0.5).cgColor
        cell.acImage.layer.borderWidth = 3
        cell.acImage.layer.masksToBounds = true
        cell.acImage.layer.cornerRadius = cell.acImage.frame.size.width / 2
       
        cell.acLabel.text = imageArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let name = imageArray[indexPath.row]
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

