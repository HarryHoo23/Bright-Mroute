//
//  SignUpViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 7/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
// This Class handle the sign up action for users.

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
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var handle: AuthStateDidChangeListenerHandle?
    var roadAssistance = [String]()
    var roadProvider = [provider]()
    var selectedProvider: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailAddressTextField.delegate = self
        repeatPasswordTextField.delegate = self
        passwordTextField.delegate = self
        roadAssistancePickerTextField.delegate = self
        self.navigationItem.title = "Sign Up"
        // all the required coded.
        signButton.changeButton() // change button view
        goBackButton.changeButton()
        createPicker() //Create a picker.
        createToolBar() // create a button with picker.
        
        profileImage.image = UIImage(named: "profile") // the default look of the profile image.
       
        //profileImage.clipsToBounds = true
        //profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderColor = UIColor.gray.cgColor
        profileImage.layer.borderWidth = 2
        let blueColor = UIColor(red: 137/255, green: 196/255, blue: 244/255, alpha: 1)
        let grayColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        backgroundView.setGradientBackgroundColor(colorOne: blueColor, colorTwo: grayColor)
        view.setGradientBackgroundColor(colorOne: blueColor, colorTwo: grayColor)
        imageTap()// allow user to tap the picture to choose the profile pic.
        let backButton = UIBarButtonItem(title: "< Back", style: .done, target: self, action: #selector(goBack)) // add a back button.
        self.navigationItem.leftBarButtonItem = backButton
        activityIndicator.isHidden = true // hide the activity indicator.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveRoadAssistance() // retrieve data from database and add into picker.
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in // required code for firebase.
            if user != nil{
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!) //if signed up, remove the listener and log in.
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
        
        if isValidEmail(testStr: email) == false { // check email validation.
            displayErrorMessage("The email address is not correct!", "Wrong Email Address")
        }
        
        guard let roadAssist = roadAssistancePickerTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (auth, error) in // create a user and add into firebase database.
            guard let uid = auth?.user.uid else {return}
            if error == nil && auth != nil {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating() // when it's signing up, show activity loading indicator.
                UIApplication.shared.beginIgnoringInteractionEvents() //disable user to touch
                let storageRef = Storage.storage().reference().child("\(uid).png") //add picture.
                if let upload = self.profileImage.image!.pngData(){
                    storageRef.putData(upload, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            self.displayErrorMessage(error!.localizedDescription, "Error")
                        } else {
                            storageRef.downloadURL(completion: { (url, error) in
                                let values = ["firstName": firstname, "lastName": lastName, "email": email, "profileImageUrl": url?.absoluteString, "roadAssistance" : roadAssist] // get the download url for image and save into database, save as an object in array.
                                self.registerUserIntoDatabaseWithUid(uid: uid, values: values as [String : AnyObject]) // save into database.
                            })
                        }
                    })
                }
            }else {
                self.displayMessage(error!.localizedDescription, "Error")
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUid(uid: String, values: [String :AnyObject]){ // the functoin that save everything into database.
        let ref = Database.database().reference(fromURL: "https://mroute-project.firebaseio.com/")
        let usersReference = ref.child("Users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                self.displayErrorMessage(err!.localizedDescription, "Error")
                return
            } else {
                print("Successfully saved into database")
                self.displayMessage("The Account Was Created Successfully!", "Success") // show message that everything ok.
                self.activityIndicator.stopAnimating() // stop the indicator.
                self.activityIndicator.isHidden = true //hide the indicator.
                UIApplication.shared.endIgnoringInteractionEvents() // let user start the action.
            }
        })
    }
    
    @IBAction func goBackPage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil) // go back to login page.
    }
    
    func createPicker(){
        let picker = UIPickerView()
        picker.delegate = self
        roadAssistancePickerTextField.inputView = picker
    }
    
    func createToolBar(){ // create the tool bar.
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SignUpViewController.dismissKeyboard)) // add a button.
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        roadAssistancePickerTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
        // dismiss the picker.
    }
    
    func imageTap(){
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImage))) // let user tap the image.
        profileImage.isUserInteractionEnabled = true
    }
    
    @objc func tapImage(){
        let picker = UIImagePickerController() // pick a picture.
        present(picker, animated: true, completion: nil)
        picker.delegate = self
        picker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
        // pick the picture.
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = pickedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        if let selectImage = selectedImage {
            profileImage.image = selectImage
        }
        dismiss(animated: true, completion: nil) // dismiss the photo picker.
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveRoadAssistance(){ // save the providers into picker.
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
    
    func displayMessage(_ message: String, _ title: String) { // show message.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) {action -> Void in
                self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayErrorMessage(_ message: String, _ title: String) { // show different type message.
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
        backgroundView.endEditing(true)
        view.endEditing(true)
        scrollView.endEditing(true)
    }
    
    func isValidEmail(testStr:String) -> Bool { // email address validation check
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" //regex.
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension SignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource{ // the picker add all the rows.
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
