//
//  EditProfileViewController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 13/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class EditProfileViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let session = SessionManager.getObject()
    
    @IBOutlet weak var edtNama: UITextField!
    @IBOutlet weak var edtEmail: UITextField!
    @IBOutlet weak var edtNoTelp: UITextField!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var ivBanner: UIImageView!
    @IBOutlet weak var ivBackground: UIImageView!
    var pbLoading: progressLoading = progressLoading()
    var imagePicker = UIImagePickerController()
    var statePicker = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ivProfile.layer.cornerRadius = ivProfile.frame.size.height/2
        ivProfile.layer.borderWidth = 4
        ivProfile.layer.borderColor = UIColor.white.cgColor
        ivProfile.clipsToBounds = true
        
        ivBackground.layer.cornerRadius = ivProfile.frame.size.height/2
        ivBackground.layer.borderWidth = 4
        ivBackground.layer.borderColor = UIColor.white.cgColor
        ivBackground.clipsToBounds = true
        
        ivBanner.layer.masksToBounds = true
        ivBanner.clipsToBounds = true
        
        self.getProfileData()
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(sender:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        
        DispatchQueue.main.async {
            self.view.frame.origin.y = -150 // Move view 150 points upward
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        
        DispatchQueue.main.async {
            self.view.frame.origin.y = 0 // Move view to original position
        }
    }

    func getProfileData(){
        
        self.showLoading()
        let url = URL(string: ServerURL.getProfile)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        
        request.httpMethod = "GET"
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.hideLoading()
            if data != nil {
                
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? [String: String]
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            //CustomToast.show(message: message ?? "", controller: self)
                            
                            if status == 200 {
                                
                                DispatchQueue.main.async {
                                    
                                    self.edtNama.text = responseApi?["profile_name"]
                                    self.edtEmail.text = responseApi?["email"]
                                    self.edtNoTelp.text = responseApi?["no_telp"]
                                    
                                    let urlImage = URL(string: ((responseApi!["foto"]))!.replacingOccurrences(of: " ", with: "%20"))
                                    
                                    if urlImage != nil {
                                        
                                        let data = try? Data(contentsOf: urlImage!)
                                        
                                        if let imageData = data {
                                            let image = UIImage(data: imageData)
                                            self.ivProfile.image = image
                                        }
                                    }
                                    
                                    let backgroundImage = URL(string: ((responseApi!["background"]))!.replacingOccurrences(of: " ", with: "%20"))
                                    
                                    
                                    if backgroundImage != nil {
                                        
                                        let data = try? Data(contentsOf: backgroundImage!)
                                        
                                        if let imageData = data {
                                            let image = UIImage(data: imageData)
                                            self.ivBanner.image = image
                                        }
                                    }
                                }
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }
                            
                        }catch let parsingError{
                            
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
            }else{
                
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    
    @IBAction func onBannerImageChange(_ sender: Any) {
        
        self.statePicker = 1;
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            self.imagePicker.delegate = self
            //self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.sourceType = .photoLibrary
            // bila ingin kamera
            //picker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            
            present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func onProfileImageChange(_ sender: Any) {
 
        self.statePicker = 0;
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            self.imagePicker.delegate = self
            //self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.sourceType = .photoLibrary
            // bila ingin kamera
            //picker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            
            present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        imagePicker.dismiss(animated: true, completion: nil)
        if self.statePicker == 0 { // profile
         
            ivProfile.image = image
        }else{ // banner
            
            ivBanner.image = image
        }
    }
    
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    
    @IBAction func onSaveClicked(_ sender: Any) {
    
        let alert = UIAlertController(title: "Konfirmasi", message: "Anda yakin ingin menyimpan data anda?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.saveData()
        }))
        
        alert.addAction(UIAlertAction(title: "Batal", style: .default, handler: { action in
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onCancelClicked(_ sender: Any) {
    
        DispatchQueue.main.async {
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func saveData(){
        
        self.showLoading()
        let url = URL(string: ServerURL.saveProfile)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        
        var imgBanner = "";
        if self.ivBanner.image != nil {
            imgBanner = self.convertImageToBase64(image: self.ivBanner.image!)
        }
        
        var imgProfile = "";
        if self.ivProfile.image != nil {
            imgProfile = self.convertImageToBase64(image: self.ivProfile.image!)
        }
        
        let data : [String: Any] =
            ["email": self.edtEmail.text
                , "profile_name": self.edtNama.text
                , "foto": imgProfile
                , "no_telp": self.edtNoTelp.text
                , "background": imgBanner
        ]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
            request.httpMethod = "POST"
            
        }catch{
            
        }
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.hideLoading()
            if data != nil {
                
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? [String: String]
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            DispatchQueue.main.async {
                                CustomToast.show(message: message ?? "", controller: self)
                                
                            }
                            
                            if status == 200 {
                                
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }
                            
                        }catch let parsingError{
                            
                            self.hideLoading()
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
            }else{
                
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    func showLoading(){
        
        DispatchQueue.main.async {
            
            self.pbLoading.showActivityIndicator(uiView: self.view)
        }
    }
    
    func hideLoading(){
        
        DispatchQueue.main.async {
            
            self.pbLoading.hideActivityIndicator(uiView: self.view)
        }
    }
    
    func redirectToLogin(){
        
        DispatchQueue.main.async {
            
            ViewController.specialState = 1
            let firebaseAuth = Auth.auth()
            
            // logout FB
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
