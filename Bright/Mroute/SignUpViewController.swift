//
//  SignUpViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 7/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import UIKit
import Firebase


class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var roadAssistancePickerTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    let roadProvider = ["--Select--",
                        "RACV",
                        "365 RoadSide",
                        "Budget Direct"]
    var selectedProvider: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        signButton.changeButton()
        goBackButton.changeButton()
        createPicker()
        createToolBar()
        profileImage.image = UIImage(named: "profile")
        imageTap()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

        Auth.auth().createUser(withEmail: email, password: password) { (auth, error) in
            guard let uid = auth?.user.uid else {return}
            if error == nil && auth != nil {
                let storageRef = Storage.storage().reference().child("MyImage.png")
                if let upload = self.profileImage.image!.pngData(){
                    storageRef.putData(upload, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        } else {
                            storageRef.downloadURL(completion: { (url, error) in
                                let values = ["firstName": firstname, "lastName": lastName, "email": email, "profileImageUrl": url?.absoluteString]
                                self.registerUserIntoDatabaseWithUid(uid: uid, values: values as [String : AnyObject])
                            })
                        }
                    })
                }
            }else {
                print(error?.localizedDescription)
                self.displayMessage(error!.localizedDescription, "Error")
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUid(uid: String, values: [String :AnyObject]){
        let ref = Database.database().reference(fromURL: "https://mroute-project.firebaseio.com/")
        let usersReference = ref.child("Users").child(uid)
        //let values = ["firstName": firstname, "lastName": lastName, "email": email]
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err?.localizedDescription)
                return
            } else {
                print("Successfully saved into database")
                self.displayMessage("The Account Was Created Successfully!", "Success")
                self.dismiss(animated: false, completion: nil)
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
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
//            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.allowsEditing = true
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//        else {
//            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//        }
//        
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
    
    func displayMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    
}

extension SignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roadProvider.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roadProvider[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedProvider = roadProvider[row]
        roadAssistancePickerTextField.text = selectedProvider
    }
}
