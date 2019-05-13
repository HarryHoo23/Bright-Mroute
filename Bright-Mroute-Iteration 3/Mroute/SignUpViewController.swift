//
//  SignUpViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 7/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import UIKit
import Firebase


class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var roadAssistancePickerTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var handle: AuthStateDidChangeListenerHandle?
    var roadAssistance = [String]()
    var roadProvider = [provider]()
    var selectedProvider: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
        self.navigationItem.title = "Sign Up"
        signButton.changeButton()
        goBackButton.changeButton()
        createPicker()
        createToolBar()
        profileImage.image = UIImage(named: "profile")
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderColor = UIColor.gray.cgColor
        profileImage.layer.borderWidth = 2
        let blueColor = UIColor(red: 137/255, green: 196/255, blue: 244/255, alpha: 1)
        let grayColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        backgroundView.setGradientBackgroundColor(colorOne: blueColor, colorTwo: grayColor)
        view.setGradientBackgroundColor(colorOne: blueColor, colorTwo: grayColor)
        imageTap()
        let backButton = UIBarButtonItem(title: "< Back", style: .done, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backButton
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveRoadAssistance()
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if user != nil{
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func createUser(_ sender: Any) {
        guard let firstname = firstNameTextField.text else{ return }
        guard let lastName = lastNameTextField.text else { return }
        guard let email = emailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let confirmPassword = repeatPasswordTextField.text, repeatPasswordTextField.text == password  else {
            displayErrorMessage("Two password doesn't match each other!", "Error")
            return
        }
        
        if isValidEmail(testStr: email) == false {
            displayErrorMessage("The email address is not correct!", "Wrong Email Address")
        }
        
        guard let roadAssist = roadAssistancePickerTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (auth, error) in
            guard let uid = auth?.user.uid else {return}
            if error == nil && auth != nil {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                let storageRef = Storage.storage().reference().child("\(uid).png")
                if let upload = self.profileImage.image!.pngData(){
                    storageRef.putData(upload, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            self.displayErrorMessage(error!.localizedDescription, "Error")
                        } else {
                            storageRef.downloadURL(completion: { (url, error) in
                                let values = ["firstName": firstname, "lastName": lastName, "email": email, "profileImageUrl": url?.absoluteString, "roadAssistance" : roadAssist]
                                self.registerUserIntoDatabaseWithUid(uid: uid, values: values as [String : AnyObject])
                            })
                        }
                    })
                }
            }else {
                self.displayMessage(error!.localizedDescription, "Error")
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUid(uid: String, values: [String :AnyObject]){
        let ref = Database.database().reference(fromURL: "https://mroute-project.firebaseio.com/")
        let usersReference = ref.child("Users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                self.displayErrorMessage(err!.localizedDescription, "Error")
                return
            } else {
                print("Successfully saved into database")
                self.displayMessage("The Account Was Created Successfully!", "Success")
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        })
    }
    
    @IBAction func goBackPage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createPicker(){
        let picker = UIPickerView()
        picker.delegate = self
        roadAssistancePickerTextField.inputView = picker
    }
    
    func createToolBar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SignUpViewController.dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        roadAssistancePickerTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func imageTap(){
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImage)))
        profileImage.isUserInteractionEnabled = true
    }
    
    @objc func tapImage(){
        let picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
        picker.delegate = self
        picker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        var selectedImage : UIImage?
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = pickedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectImage = selectedImage {
            profileImage.image = selectImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveRoadAssistance(){
        var road = [String]()
        let ref = Database.database().reference().child("RoadAssistance")
        ref.observe(.value, with: { (snapshot) in
            for data in snapshot.children.allObjects as! [DataSnapshot]{
                let object = data.value as? [String : AnyObject]
                let name = object?["Company"] as! String
                road.append(name)
                self.roadAssistance.append(name)
            }
        })
    }
    
    func displayMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) {action -> Void in
                self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayErrorMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let dismissAction: UIAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension SignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roadAssistance.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roadAssistance[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedProvider = roadAssistance[row]
        roadAssistancePickerTextField.text = selectedProvider
    }
}
