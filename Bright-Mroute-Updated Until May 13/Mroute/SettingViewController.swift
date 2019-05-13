//
//  SeetingViewController.swift
//  Mroute
//
//  Created by zhongheng on 9/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
// This viewController will be responsible for iteration 3 that set up user's profile.

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
        // Make the profile picture as circle.
        profilePicImage.layer.borderWidth = 2
        profilePicImage.layer.borderColor = UIColor.gray.cgColor
        // Set the border color.
        let signOutButton = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(tapButton))
        self.navigationItem.rightBarButtonItem = signOutButton
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn(){ // check if a user is logging or not.
        if Auth.auth().currentUser?.uid == nil {
            print("Not Logged in.")
            self.dismiss(animated: true, completion: nil)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("Users").child(uid!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.name = dictionary["firstName"] as? String
                    self.roadAssist = dictionary["roadAssistance"] as? String
                    self.nameLabel.text = "Welcome " + self.name!
                    self.providerLabel.text = "Your Provider: " + self.roadAssist!
                    let imageUrl = dictionary["profileImageUrl"] as? String
                    self.profilePicImage.download(from: imageUrl!) // add picture.
                }
            })
        }
    }
    
    @objc func tapButton(){ // the sign out button action.
        do {
            try Auth.auth().signOut()
        }catch {
            print("Error")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
