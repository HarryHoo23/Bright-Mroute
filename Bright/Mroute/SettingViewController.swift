//
//  SeetingViewController.swift
//  Mroute
//
//  Created by zhongheng on 9/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//This viewController will be responsible for iteration 2 that set up user's preference in emergency contact.

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    var name: String?
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            print("Not Logged in.")
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("Users").child(uid!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.name = dictionary["firstName"] as? String
                    self.nameLabel.text = "Welcome " + self.name!
                }
            })
        }
    }
    
}
