//
//  MapPopUpViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 28/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//


import UIKit
import MapKit

class MapPopUpViewController: UIViewController { //  This view is responsible for the PopUp view when click on the parking lot annotation.

    var annotation: MKAnnotation?
    var status: String?
    var duration: String?
    var time: String?
    var marker: String?
    var bayId: Int64?
    var days: String?
    var timeDuration: Int?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var bayLabel: UILabel!
    @IBOutlet weak var markerIdLabel: UILabel!
    @IBOutlet weak var durationImage: UIImageView!
    
    @IBAction func navigation(_ sender: Any) {
        //the navigation function when click on the button.
        let location = annotation as! Annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    
    @IBAction func closeViewButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        //PopUp window will disappear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.showAnimate()

        if status == "Unoccupied" {
            nameLabel.text = status!
            nameLabel.textColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
        } else {
            nameLabel.text = status!
            nameLabel.textColor = UIColor.red
        } // show different color if the status is different.
        
        detailLabel.text = duration! + " (\(time!))"
        dayLabel.text = "From: " + days! + " \(timeDuration!) Mins"
        bayLabel.text = "Bay:  \(bayId!)"
        markerIdLabel.text = "Street marker: " + marker!
        let pFifteen = "15P"
        let pThirty = "30P"
        
        if duration == "1/4P" {
            durationImage.image = UIImage(named:pFifteen)
        } else if duration == "1/2P" {
            durationImage.image = UIImage(named: pThirty)
        } else{
            durationImage.image = UIImage(named:"\(duration!)")
        }
        
        // Do any additional setup after loading the view.
    }
    
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3,y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            //show the animation when the PopUp view is showend.
        }
    }
}
