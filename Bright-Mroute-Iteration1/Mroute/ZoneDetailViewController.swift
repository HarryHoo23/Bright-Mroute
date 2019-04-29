//
//  zoneDetailViewController.swift
//  Mroute
//
//  Created by zhongheng on 7/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//This viewController shows the detail of the prone zones and hook turns when user click the annotation on the map

import UIKit
import MapKit

class ZoneDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var turnImageView: UIImageView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var turnInstructionImageView: UIImageView!
    
    var name: String?
    var speedZone: String?
    var latitude: Double?
    var longitude : Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel()
        getAddress()
        // Do any additional setup after loading the view.
    }
    
    //this function is the geocoder, transfer the coordinate to address.
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
    
    //The function that is responsible for the view to show people.
    func detailLabel(){
        if speedZone == "Hook Turn"{
            titleLabel.text = speedZone! + " Detail"
            nameLabel.text = ""
            typeLabel.text = "Sign Picture"
            turnImageView.image = UIImage(named: "HookTurn")
            instructionLabel.text = "Instruction About How to Turn: "
            turnInstructionImageView.image = UIImage(named: "HookInstruction")
        }else{
            titleLabel.text = "Prone Zone Detail"
            nameLabel.text = "Road Type: " + name!
            typeLabel.text = speedZone!
            instructionLabel.text = ""
        }
    }
    
}
