//
//  CyclistsViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 11/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//  This cyclist class, shows the routes of bike, allow user to choose the bike route they want.

import UIKit

class CyclistsViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var routeTableView: UITableView!

    let route = ["Portsea Return", "The Dandenongs Ranges", "Yarra Glen", "Kinglake", "Mornington + Two Bays", "Beach Road", "Yarra Boulevard"]
    let imageArray = ["Portsea", "dandenong", "yarraglen", "kinglake", "mornington", "stkilda", "yarra"]
    //Create two array that saves the name of the route, and picture.
    
    var image: UIImage?
    var name: String?
    var number: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoLabel.text = "Don't own a bike?\n\nNo Problem, Click here to hire one." //Show basic info
        routeTableView.delegate = self
        routeTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.routeTableView.reloadData()
    }
}


extension CyclistsViewController: UITableViewDelegate, UITableViewDataSource { // the code that indicate the tableview.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return route.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeIdentifier", for: indexPath) as! RouteTableViewCell
        self.routeTableView.rowHeight = 80
        cell.routeImage.image = UIImage(named: imageArray[indexPath.row])
        cell.routeInformationlabel.text = "\(indexPath.row + 1). " + route[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.routeTableView.allowsSelection = true
        name = route[indexPath.row]
        image = UIImage(named: imageArray[indexPath.row])
        number = indexPath.row
        print(number!)
        self.performSegue(withIdentifier: "showDetail", sender: self) // show the deatil page of the route.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // pass all the data to the next view page.
        if (segue.identifier == "showDetail")
        {
            let controller = segue.destination as! RouteDetailViewController
            controller.name = self.name
            controller.picture = self.image
            controller.position = self.number
        }
    }
    
}


