//
//  LoginViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 7/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
// This page handle the login function for user.

import UIKit
import Firebase
import MapKit

class LoginViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    var locationManager: CLLocationManager = CLLocationManager()
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization() // request user's location
        self.locationManager.requestWhenInUseAuthorization()
        loginButton.changeButton() // change button type.
        signUpButton.changeButton()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "loginSegue", sender: self) // if loggin succeed, go to another page.
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.backgroundImage.loadGif(name: "background") // change the background of the application into a Gif.
        }
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if user != nil{
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    @IBAction func loginAction(_ sender: Any) {
        guard let email = emailTextField.text else {
            print("error")
            return
        }
        
        guard let password = passwordTextField.text else {
            print("error")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
                self.displayMessage(error!.localizedDescription, "Error")
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: self) //login succesfully
            }
        }
    }
    
    func displayMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //dismiss the keyboard.
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        //dismiss the keyboard.
    }
    
}

extension UIButton {
    func changeButton(){ //change the button type.
        self.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
