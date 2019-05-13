//
//  RouteDetailViewController.swift
//  Mroute
//
//  Created by zhongheng on 13/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import UIKit
import MapKit

class RouteDetailViewController: UIViewController, MKMapViewDelegate {

    var name: String?
    var picture: UIImage?
    var position: Int?
    let routeDetail = ["Distance: 185km, Elevation: 1,800m \nRoute: Portsea Return \nLevel: Expert", "Distance: 85km, Elevation: 1,900m \nRoute: The Dandenongs \nLevel: Intermediate", "Distance: 96km, Elevation: 1,700m \nRoute: Yarra Glen \nLevel: Intermediate", "Distance: 104km, Elevation: 1,800m \nRoute: Kinglake \nLevel: Expert", "Distance: 108km, Elevation: 1,300m \nRoute: Mornington + Two Bays \nLevel: Expert", "Distance: 45km, Elevation: 600m \nRoute: Beach Road \nLevel: Beginner", "Distance: 39km, Elevation: 600m \nRoute: Yarra Boulevard \nLevel: Beginner"] // the route detail array
    let webUrlArray = ["https://goo.gl/maps/jzCvoXHWyi3RDJWUA","https://goo.gl/maps/cM3qJyawza296VWL7","https://goo.gl/maps/7r1bpKAyHq5BDWaw6", "https://goo.gl/maps/WF6mEdn7D3oTaGR4A", "https://goo.gl/maps/4nrRWjAXmfMbChJj7", "https://goo.gl/maps/FiGBmMi976oqJwpAA", "https://goo.gl/maps/WXJPiWSPLAzhn1ow8"] // the web of google map link array.
    
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var routeMap: MKMapView!
    
    //Save all the point that needs for draw a line on map.
    
    let beginLocation = CLLocationCoordinate2D(latitude: -37.866660, longitude: 144.973990)
    let middlePoint = CLLocationCoordinate2D(latitude: -38.339450, longitude: 144.740240)
    let endingLocation = CLLocationCoordinate2D(latitude: -37.866660, longitude: 144.973990)
    
    let one = CLLocationCoordinate2D(latitude: -37.826810, longitude: 145.057270)
    let second = CLLocationCoordinate2D(latitude: -37.863660, longitude: 145.353380)
    let third = CLLocationCoordinate2D(latitude: -37.876220, longitude: 145.355690)
    let fourth = CLLocationCoordinate2D(latitude: -37.855700, longitude: 145.364930)
    let fifth = CLLocationCoordinate2D(latitude: -37.826810, longitude: 145.057270)
    
    let yarra1 = CLLocationCoordinate2D(latitude: -37.829860, longitude: 145.058330)
    let yarra2 = CLLocationCoordinate2D(latitude: -37.691510, longitude: 145.215790)
    let yarra3 = CLLocationCoordinate2D(latitude: -37.657530, longitude: 145.375000)
    let yarra4 = CLLocationCoordinate2D(latitude: -37.791809, longitude: 145.093643)
    let yarra5 = CLLocationCoordinate2D(latitude: -37.829860, longitude: 145.058330)
    
    let kinglake1 = CLLocationCoordinate2D(latitude: -37.829861, longitude: 145.058334)
    let kinglake2 = CLLocationCoordinate2D(latitude: -37.605130, longitude: 145.266770)
    let kinglake3 = CLLocationCoordinate2D(latitude: -37.567390, longitude: 145.305850)
    let kinglake4 = CLLocationCoordinate2D(latitude: -37.605130, longitude: 145.266770)
    let kinglake5 = CLLocationCoordinate2D(latitude: -37.691510, longitude: 145.215790)
    let kinglake6 = CLLocationCoordinate2D(latitude: -37.742150, longitude: 145.211320)
    let kinglake7 = CLLocationCoordinate2D(latitude: -37.787580, longitude: 145.132070)
    let kinglake8 = CLLocationCoordinate2D(latitude: -37.829861, longitude: 145.058334)
    
    let mornington1 = CLLocationCoordinate2D(latitude: -37.866661, longitude: 144.973984)
    let mornington2 = CLLocationCoordinate2D(latitude: -38.012790, longitude: 145.092620)
    let mornington3 = CLLocationCoordinate2D(latitude: -38.202380, longitude: 145.117060)
    let mornington4 = CLLocationCoordinate2D(latitude: -38.211570, longitude: 145.050990)
    let mornington5 = CLLocationCoordinate2D(latitude: -38.012790, longitude: 145.092620)
    let mornington6 = CLLocationCoordinate2D(latitude: -37.866661, longitude: 144.973984)
    
    let beach1 = CLLocationCoordinate2D(latitude: -37.866661, longitude: 144.973984)
    let beach2 = CLLocationCoordinate2D(latitude: -37.992031, longitude: 145.041779)
    let beach3 = CLLocationCoordinate2D(latitude: -38.008940, longitude: 145.086350)
    let beach4 = CLLocationCoordinate2D(latitude: -37.866661, longitude: 144.973984)
    
    let yarrab1 = CLLocationCoordinate2D(latitude: -37.829861, longitude: 145.058334)
    let yarrab2 = CLLocationCoordinate2D(latitude: -37.820060, longitude: 145.015830)
    let yarrab3 = CLLocationCoordinate2D(latitude: -37.827260, longitude: 144.990880)
    let yarrab4 = CLLocationCoordinate2D(latitude: -37.832610, longitude: 144.991650)
    let yarrab5 = CLLocationCoordinate2D(latitude: -37.820060, longitude: 145.015830)
    let yarrab6 = CLLocationCoordinate2D(latitude: -37.788410, longitude: 145.017920)
    let yarrab7 = CLLocationCoordinate2D(latitude: -37.796470, longitude: 145.019680)
    let yarrab8 = CLLocationCoordinate2D(latitude: -37.787580, longitude: 145.132070)
    let yarrab9 = CLLocationCoordinate2D(latitude: -37.793750, longitude: 145.015090)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routeMap.delegate = self
        nameLabel.text = name!
        image.image = picture!
        detail.text = routeDetail[position!]
        let yellowColor = UIColor(red: 255/255, green: 255/255, blue: 221/255, alpha: 0.8)
        let lightOrangeColor = UIColor(red: 255/255, green: 228/255, blue: 192/255, alpha: 1)
        view.setGradientBackgroundColor(colorOne: yellowColor, colorTwo: lightOrangeColor) // set the background color.
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showRoute() //show all the route.
    }
    
    func showRoute(){ // add the route on the map.
        switch position! {
        case 0:
            print("")
            self.routeMap.removeAnnotations(self.routeMap.annotations) // remove the annotations
            self.routeMap.removeOverlays(self.routeMap.overlays) // remove the line that drew before.
            addStartAnnotation(annotation: beginLocation) // add the start point on the map.
            addRoute(startLocation: beginLocation, endLocation: middlePoint)
            addRoute(startLocation: middlePoint, endLocation: endingLocation)
        case 1:
            self.routeMap.removeAnnotations(self.routeMap.annotations)
            self.routeMap.removeOverlays(self.routeMap.overlays)
            addStartAnnotation(annotation: one)
            addRoute(startLocation: one, endLocation: second)
            addRoute(startLocation: second, endLocation: third)
            addRoute(startLocation: third, endLocation: fourth)
            addRoute(startLocation: fourth, endLocation: fifth)
        case 2:
            self.routeMap.removeAnnotations(self.routeMap.annotations)
            self.routeMap.removeOverlays(self.routeMap.overlays)
            addStartAnnotation(annotation: yarra1)
            addRoute(startLocation: yarra1, endLocation: yarra2)
            addRoute(startLocation: yarra2, endLocation: yarra3)
            addRoute(startLocation: yarra3, endLocation: yarra4)
            addRoute(startLocation: yarra4, endLocation: yarra5)
        case 3:
            self.routeMap.removeAnnotations(self.routeMap.annotations)
            self.routeMap.removeOverlays(self.routeMap.overlays)
            addStartAnnotation(annotation: kinglake1)
            addRoute(startLocation: kinglake1, endLocation: kinglake2)
            addRoute(startLocation: kinglake2, endLocation: kinglake3)
            addRoute(startLocation: kinglake3, endLocation: kinglake4)
            addRoute(startLocation: kinglake4, endLocation: kinglake5)
            addRoute(startLocation: kinglake5, endLocation: kinglake6)
            addRoute(startLocation: kinglake6, endLocation: kinglake7)
            addRoute(startLocation: kinglake7, endLocation: kinglake8)
        case 4:
            self.routeMap.removeAnnotations(self.routeMap.annotations)
            self.routeMap.removeOverlays(self.routeMap.overlays)
            addStartAnnotation(annotation: mornington1)
            addRoute(startLocation: mornington1, endLocation: mornington2)
            addRoute(startLocation: mornington2, endLocation: mornington3)
            addRoute(startLocation: mornington3, endLocation: mornington4)
            addRoute(startLocation: mornington4, endLocation: mornington5)
            addRoute(startLocation: mornington5, endLocation: mornington6)
        case 5:
            self.routeMap.removeAnnotations(self.routeMap.annotations)
            self.routeMap.removeOverlays(self.routeMap.overlays)
            addStartAnnotation(annotation: beach1)
            addRoute(startLocation: beach1, endLocation: beach2)
            addRoute(startLocation: beach2, endLocation: beach3)
            addRoute(startLocation: beach3, endLocation: beach4)
        case 6:
            self.routeMap.removeAnnotations(self.routeMap.annotations)
            self.routeMap.removeOverlays(self.routeMap.overlays)
            addStartAnnotation(annotation: yarrab1)
            addRoute(startLocation: yarrab1, endLocation: yarrab2)
            addRoute(startLocation: yarrab2, endLocation: yarrab3)
            addRoute(startLocation: yarrab3, endLocation: yarrab4)
            addRoute(startLocation: yarrab4, endLocation: yarrab5)
            addRoute(startLocation: yarrab5, endLocation: yarrab6)
            addRoute(startLocation: yarrab6, endLocation: yarrab7)
            addRoute(startLocation: yarrab7, endLocation: yarrab8)
            addRoute(startLocation: yarrab8, endLocation: yarrab9)
        default:
            break
        }
    }

    func addStartAnnotation(annotation: CLLocationCoordinate2D){ // add a start point on the map.
        let lon = annotation.longitude
        let lat = annotation.latitude
        let location = CLLocation(latitude: lat, longitude: lon)
        DispatchQueue.main.async {
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                if error != nil{
                    print(error!.localizedDescription)
                }else if placemarks != nil && (placemarks?.count)! > 0 {
                    let placemark = placemarks![0]
                    let addressname = placemark.name
                    let region = placemark.administrativeArea
                    let street = placemark.locality
                    let address = addressname! + " " + street! + ", " + region!
                    let pin = Annotation(newTitle: "Start Point", subtitle: address, location: annotation)
                    self.routeMap.addAnnotation(pin)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { // change the view of annotation.
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
        let resizedSize = CGSize(width: 5, height: 5)
        UIGraphicsBeginImageContext(resizedSize)        
        annotationView.image = UIImage(named: "pin")
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        
        let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: 40, height: 40)))
        mapsButton.setBackgroundImage(UIImage(named: "mapkit"), for: UIControl.State()) // the button look like a map button.
        annotationView.rightCalloutAccessoryView = mapsButton
        // allow user to tap the annotation.
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions) // navigate to the map.
        // after tap the annotation can jump to the map to launch navigation.
    }
    
    
    func addRoute(startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D) { //draw the route function.
        let sourcePlaceMark = MKPlacemark(coordinate: startLocation, addressDictionary: nil) // start point
        let endPlaceMark = MKPlacemark(coordinate: endLocation, addressDictionary: nil) // end point
        let sourceMap = MKMapItem(placemark: sourcePlaceMark)
        let endMap = MKMapItem(placemark: endPlaceMark)
        let annotation = MKPointAnnotation()
        if let location = sourcePlaceMark.location {
            annotation.coordinate = location.coordinate
        }
        
        let endAnnotation = MKPointAnnotation()
        if let location = endPlaceMark.location {
            endAnnotation.coordinate = location.coordinate
        } // annotation.
        
        let directRequest = MKDirections.Request() //request to draw the route.
        directRequest.source = sourceMap
        directRequest.destination = endMap
        
        let direction = MKDirections(request: directRequest)
        direction.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let route = response.routes[0] // the first route.
            self.routeMap.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads) // draw the route
            let rect = route.polyline.boundingMapRect
            self.routeMap.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
  
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer { // the view of the route on the map.
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 3
        return renderer
    }
    
    @IBAction func navigateInWeb(_ sender: Any) { //when user click the button to nivigate, jump to the google map page. 
        let weburl = webUrlArray[position!]
        if let url = URL(string: weburl) {
            UIApplication.shared.open(url)
        }
    }
    
}
