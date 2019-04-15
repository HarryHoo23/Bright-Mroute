//
//  ParkingDetailViewController.swift
//  Mroute
//
//  Created by zhongheng on 7/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.

//  This class is about showing the specific location of parking when user choose from the list.

import UIKit
import MapKit

class ParkingDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var latitude: Double?
    var longitude: Double?
    var date: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailMapView.delegate = self
        getAddress()
        addAnnotation()
        let address = CLLocation(latitude: latitude!, longitude: longitude!)
        centerMapOnAnnotation(location: address)
    }
    
    
    //this function is to focus on the map annotaion
    func centerMapOnAnnotation(location: CLLocation) {
        let Radius: CLLocationDistance = 100
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: Radius, longitudinalMeters: Radius)
        detailMapView.setRegion(coordinateRegion, animated: true)
    }
    
    //This function add the annotations
    func addAnnotation(){
        let name = "Your Parking Location"
        let fenceAnnotation = CLLocationCoordinate2DMake(latitude!, longitude!)
        let parkingAnnotation = Annotation(newTitle: name, subtitle: "Time: " + date!, location: fenceAnnotation)
        self.detailMapView.addAnnotation(parkingAnnotation as MKAnnotation)
        
    }
    
    //This function is to edit the annotation view, customize your annotation view with your picture
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "fenceAnnotation")
        //let anno = annotation as! Annotation
        let resizedSize = CGSize(width: 5, height: 5)
        UIGraphicsBeginImageContext(resizedSize)
        
        annotationView.image = UIImage(named: "parkingIcon")
        // this line of code let you select your picture for annotation
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: 35, height: 35)))
        mapsButton.setBackgroundImage(UIImage(named: "maps-icon"), for: UIControl.State())
        annotationView.rightCalloutAccessoryView = mapsButton
        //mapsButton let user tap, and jump to the navigation page.
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions) // jump to the map for navigation.
    }
    
    // geocode of the address from coordinates
    func getAddress() {
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil{
                print(error!.localizedDescription)
            }else if placemarks != nil && (placemarks?.count)! > 0 {
                let placemark = placemarks![0]
                let addressname = placemark.name
                let region = placemark.administrativeArea
                let postcode = placemark.postalCode
                let country = placemark.country
                let street = placemark.locality
                self.addressLabel!.text = "Address: " + addressname! + ", " + street! + ", " + region! + " " + postcode! + ", " + country!
            }
        }
    }
    
}
