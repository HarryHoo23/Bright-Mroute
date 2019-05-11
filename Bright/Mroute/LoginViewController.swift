//
//  LoginViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 7/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.changeButton()
        signUpButton.changeButton()
        emailTextField.delegate = self
        passwordTextField.delegate = self
//        let blueColor = UIColor(red: 137/255, green: 196/255, blue: 244/255, alpha: 1)
//        let grayColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
//        //view.setGradientBackgroundColor(colorOne: blueColor, colorTwo: grayColor)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         backgroundImage.loadGif(name: "background")
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
                self.performSegue(withIdentifier: "loginSegue", sender: self)
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
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension UIButton {
    func changeButton(){
        self.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
