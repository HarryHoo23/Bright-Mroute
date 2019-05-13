//
//  BikeShareViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 12/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//  This class is handling the bike rent station on the map.

import UIKit
import MapKit

struct bikeStation: Decodable {
    let station_id: String
    let lon: String
    let lat: String
    let capacity: String
    let name: String

    init(station: String, longitude: String, latitude: String, capacity: String, stationName: String){
        station_id = station
        lon = longitude
        lat = latitude
        self.capacity = capacity
        name = stationName
    }
    
}
class BikeShareViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var bikeStationMap: MKMapView!

    var locationManager: CLLocationManager = CLLocationManager()
    var bikeShare = [bikeStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialLocation = CLLocation(latitude: -37.814, longitude: 144.96332)
        bikeStationMap.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            bikeStationMap.showsUserLocation = true
            bikeStationMap.userLocation.title = "Your Current Location"
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Please allow user location")
        }
        
        centerMapOnLocation(location: initialLocation) // center the view on the city.
        retrieveBikeData()
    }

    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 3000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        bikeStationMap.setRegion(coordinateRegion, animated: true)
    }
    
    func retrieveBikeData(){ // retrieve the data from json api.
        var bikeStationArray = [bikeStation]()
        let url = "https://data.melbourne.vic.gov.au/resource/vrwc-rwgm.json?$select=lat,lon,capacity,name,station_id"
        guard let jsonUrl = URL(string: url) else { return }
      
        URLSession.shared.dataTask(with: jsonUrl) {(data, response, error) in
            guard let data = data else{return}
           
            do {
                let bikeStationElement = try JSONDecoder().decode([bikeStation].self, from: data)
                for data in bikeStationElement {
                    let stationId = data.station_id
                    let name = data.name
                    let lon = data.lon
                    let lat = data.lat
                    let capacity = data.capacity
                    let theBikeStation = bikeStation(station: stationId, longitude: lon, latitude: lat, capacity: capacity, stationName: name)
                    bikeStationArray.append(theBikeStation)
                }
            } catch {
                print(error.localizedDescription)
            }
            self.bikeShare = bikeStationArray
            DispatchQueue.main.async {
                for element in bikeStationArray { // save the bike into the struct we created on the top.
                    let latitude = Double(element.lat)!
                    let longitude = Double(element.lon)!
                    let name = element.name
                    let stationId = element.station_id
                    let capacity = element.capacity
                    let fenceAnnotation = CLLocationCoordinate2DMake(latitude, longitude)
                    let bikeShareAnnotation = Annotation(newTitle: "Station No." + stationId + " Current Capcity: \(capacity)", subtitle: name, location: fenceAnnotation)
                    self.bikeStationMap.addAnnotation(bikeShareAnnotation as MKAnnotation)
                }
            }
        }.resume()
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.image = UIImage(named: "bikePin") // the view of the annotation pin.
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: 40, height: 40)))
        mapsButton.setBackgroundImage(UIImage(named: "mapkit"), for: UIControl.State()) // the button look like a map button.
        annotationView.rightCalloutAccessoryView = mapsButton

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions) // navigate to the map.
        // after tap the annotation can jump to the map to launch navigation.
    }
    
}
