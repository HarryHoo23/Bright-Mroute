//
//  SeetingViewController.swift
//  Mroute
//
//  Created by zhongheng on 9/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
// This viewController will be responsible for iteration 3 that set up user's profile.

import UIKit
import Firebase

class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var roadProvider: UITextField!
    var roadAssistance = [String]()
    var selectedProvider: String?
    
    var name: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicImage.clipsToBounds = true
        profilePicImage.layer.cornerRadius = profilePicImage.frame.size.width / 2
        // Make the profile picture as circle.
        profilePicImage.layer.borderWidth = 1.5
        profilePicImage.layer.borderColor = UIColor.gray.cgColor
        // Set the border color.
        
        let yellowColor = UIColor(red: 255/255, green: 255/255, blue: 221/255, alpha: 0.8) // create two different color.
        let lightOrangeColor = UIColor(red: 255/255, green: 228/255, blue: 192/255, alpha: 1)
        view.setGradientBackgroundColor(colorOne: lightOrangeColor, colorTwo: yellowColor) // set the background color.
        let signOutButton = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(tapButton))
        self.navigationItem.rightBarButtonItem = signOutButton
        imageTap()
        createPicker()
        createToolBar()
        checkIfUserIsLoggedIn()
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveRoadAssistance()
    }
    
    func imageTap(){
    profilePicImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImage))) // let user tap the image.
        profilePicImage.isUserInteractionEnabled = true
    }
    
    @objc func tapImage(){ // allow user to tap the image
        let picker = UIImagePickerController() // pick a picture.
        present(picker, animated: true, completion: nil)
        picker.delegate = self
        picker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        // this function is handling the picture choose from the phone.
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
            profilePicImage.image = selectImage
        }
        dismiss(animated: true, completion: nil) // dismiss the photo picker.
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn(){ // check if a user is logging or not.
        if Auth.auth().currentUser?.uid == nil {
            print("Not Logged in.")
            self.dismiss(animated: true, completion: nil)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("BrightMroute").child("Users").child(uid!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.name = dictionary["firstName"] as? String
                    let roadAssist = dictionary["roadAssistance"] as? String
                    self.nameLabel.text = "Welcome " + self.name!
                    self.providerLabel.text = "Your road assistance: " + roadAssist!
                    let imageUrl = dictionary["profileImageUrl"] as? String
                    self.profilePicImage.download(from: imageUrl!) // add picture.
                }
            })
        }
    }
    
    @IBAction func updateProfileInformation(_ sender: Any) {
        guard let roadAssist = roadProvider.text, roadProvider.text!.count > 0 else {
            displayErrorMessage("Please choose a Road Assistance Provider!", "Error")
            return
        }
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("BrightMroute").child("Users")
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("\(imageName).png") // save image as unique name.
        DispatchQueue.main.async {
            if let upload = self.profilePicImage.image?.jpeg(.lowest) //compress the original image size and save into the database.
            {
                storageRef.putData(upload, metadata: nil, completion: { ( metadata, error) in
                    if error != nil {
                        self.displayErrorMessage(error!.localizedDescription, "Error")
                    } else {
                        storageRef.downloadURL(completion: { (url, error) in
                            ref.child(uid!).updateChildValues(["profileImageUrl" : url?.absoluteString])
                            //update the image donwload url string.
                        })
                    }
                })
            }
        }
        ref.child(uid!).updateChildValues(["roadAssistance" : roadAssist])
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { // start the function after 3 seconds.
            //if we don't delay the funciton, then after updating, the picture won't change.
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            UIApplication.shared.endIgnoringInteractionEvents()
            //self.view.setNeedsLayout()
            //self.viewWillAppear(true)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    func createPicker(){
        let picker = UIPickerView()
        picker.delegate = self
        roadProvider.inputView = picker
    }
    
    func createToolBar(){ // create the tool bar.
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard)) // add a button.
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        roadProvider.inputAccessoryView = toolbar
    }
    
    func saveRoadAssistance(){ // save the providers into select picker.
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
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
        // dismiss the picker.
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

extension SettingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        roadProvider.text = selectedProvider
    }
    
    func displayErrorMessage(_ message: String, _ title: String) { // show different type message.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let dismissAction: UIAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIImage { // this is going to compress the image size.
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
