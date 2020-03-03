//
//  ProfileViewController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 11/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class ProfileViewController: UIViewController {

    let session = SessionManager.getObject()
    
    @IBOutlet weak var tvNama: UILabel!
    @IBOutlet weak var tvEmail: UILabel!
    @IBOutlet weak var tvTelepon: UILabel!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var ivBanner: UIImageView!
    var pbLoading: progressLoading = progressLoading()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ivProfile.layer.cornerRadius = ivProfile.frame.size.height/2
        ivProfile.layer.borderWidth = 4
        ivProfile.layer.borderColor = UIColor.white.cgColor
        ivProfile.clipsToBounds = true
        
        ivBanner.layer.masksToBounds = true
        ivBanner.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        self.getProfileData()
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
                                    
                                    self.tvNama.text = responseApi?["profile_name"]
                                    self.tvEmail.text = responseApi?["email"]
                                    self.tvTelepon.text = responseApi?["no_telp"]
                                    
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

    @IBAction func onSettingClicked(_ sender: Any) {

        let alertController = UIAlertController(title: "Profile", message: "", preferredStyle: .alert)
        
        let editProfile = UIAlertAction(title: NSLocalizedString("Edit Profile", comment: "profile"), style: .default, handler: {(action: UIAlertAction) -> Void in
            
            self.performSegue(withIdentifier: "segEditProfile", sender: self)
        })
        
        let editSignout = UIAlertAction(title: NSLocalizedString("Sign Out", comment: "signout"), style: .default, handler: {(action: UIAlertAction) -> Void in
            
            let alert = UIAlertController(title: "Konfirmasi", message: "Anda yakin ingin Signout?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
                let firebaseAuth = Auth.auth()
                
                // logout FB
                do {
                    
                    //logout facebook
                    let loginManager = LoginManager()
                    loginManager.logOut()
                    
                    //logout google
                    GIDSignIn.sharedInstance().signOut()
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Batal", style: .default, handler: { action in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel"), style: .default, handler: {(action: UIAlertAction) -> Void in
            print("cancel action")
        })
        
        alertController.addAction(editProfile)
        alertController.addAction(editSignout)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)

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
    
}
