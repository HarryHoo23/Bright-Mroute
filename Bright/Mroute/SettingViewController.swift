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
    
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    
    var name: String?
    var roadAssist: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicImage.clipsToBounds = true
        profilePicImage.layer.cornerRadius = profilePicImage.frame.size.width / 2
        let signOutButton = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(tapButton))
        self.navigationItem.rightBarButtonItem = signOutButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            print("Not Logged in.")
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("Users").child(uid!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.name = dictionary["firstName"] as? String
                    self.roadAssist = dictionary["roadAssistance"] as? String
                    self.nameLabel.text = "Welcome " + self.name!
                    self.providerLabel.text = "Your Provider: " + self.roadAssist!
                }
            })
            let url = Storage.storage().reference().child("\(uid!).png")
            
            DispatchQueue.main.async {
                url.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }else {
                        self.profilePicImage.image = UIImage(data: data!)
                    }
                }
            }
        }
    }
    
    @objc func tapButton(){
        do {
            try Auth.auth().signOut()
        }catch {}
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
