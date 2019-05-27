//
//  ResetPasswordViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 11/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddress.delegate = self
        //add the background color.
        let blueColor = UIColor(red: 137/255, green: 196/255, blue: 244/255, alpha: 1)
        let grayColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        view.setGradientBackgroundColor(colorOne: blueColor, colorTwo: grayColor)
        let backButton = UIBarButtonItem(title: "< Back", style: .done, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = "Reset Your Password"
    }
    
    
    @IBAction func sendEmail(_ sender: Any) {
        guard let email = emailAddress.text else {return}
        if isValidEmail(testStr: email) == false {
            displayErrorMessage("The email is invalid, please check!", "Invalid Email Address") // error message
        }
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in // send the email to reset the password
            if error != nil {
                print(error?.localizedDescription) // error message
            }else {
                self.displayMessage("A password reset email has been sent, please check your email", "Email Sent")
            }
        }
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayErrorMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let dismissAction: UIAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) {action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
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
